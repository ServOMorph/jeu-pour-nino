extends AcceptDialog
class_name SheetEditorDialog

signal sheet_saved(entity: String, state: String)

const PathUtilsScript := preload("res://editeur/path_utils.gd")
const SheetEditorCanvasScript := preload("res://editeur/sheet_editor_canvas.gd")
const CONTENT_MARGIN := Vector2(32.0, 96.0)

var _canvas: SheetEditorCanvasScript
var _entity := ""
var _state := ""
var _disk_path := ""

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	title = "Editeur de sheet"
	min_size = Vector2i(720, 560)
	get_ok_button().hide()

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	_canvas = SheetEditorCanvasScript.new()
	scroll.add_child(_canvas)

	var actions := HBoxContainer.new()
	root.add_child(actions)

	var btn_validate := Button.new()
	btn_validate.text = "Valider"
	btn_validate.pressed.connect(_on_validate_pressed)
	actions.add_child(btn_validate)

	var btn_cancel := Button.new()
	btn_cancel.text = "Annuler"
	btn_cancel.pressed.connect(hide)
	actions.add_child(btn_cancel)

func open_for(entity: String, state: String, cfg: Dictionary) -> void:
	_entity = entity
	_state = state
	var sheet_path := String(cfg.get("sheet", ""))
	if sheet_path.is_empty():
		return
	_disk_path = PathUtilsScript.editor_path(sheet_path)
	var image := Image.load_from_file(ProjectSettings.globalize_path(_disk_path))
	if image == null or image.is_empty():
		push_warning("sheet introuvable pour edition: " + _disk_path)
		return

	var fsz: Variant = cfg.get("frame_size", [16, 16])
	var frame_size := Vector2i(16, 16)
	if fsz is Array and fsz.size() >= 2:
		frame_size = Vector2i(int(fsz[0]), int(fsz[1]))

	var frames: Variant = cfg.get("frames", [])
	_canvas.setup(image, frame_size, frames if frames is Array else [])
	var available: Vector2 = Vector2(min_size) - CONTENT_MARGIN
	available.x = maxf(available.x, 100.0)
	available.y = maxf(available.y, 100.0)
	_canvas.fit_to(available)
	if is_inside_tree():
		popup_centered()

func _on_validate_pressed() -> void:
	if _apply_and_save():
		hide()
		sheet_saved.emit(_entity, _state)

func _apply_and_save() -> bool:
	var abs_path := ProjectSettings.globalize_path(_disk_path)
	var original := Image.load_from_file(abs_path)
	if original == null or original.is_empty():
		return false
	var out_image := original.duplicate()

	var fw := _canvas.get_frame_size().x
	var fh := _canvas.get_frame_size().y
	var cols := _canvas.get_cols()
	var edits: Dictionary = _canvas.get_frame_edits()

	for raw_idx in edits.keys():
		var idx := int(raw_idx)
		var edit: Dictionary = edits[idx]
		var bbox: Rect2i = edit["bbox"]
		if bbox.size == Vector2i.ZERO:
			continue

		var scale: float = edit["scale"]
		var offset: Vector2 = edit["offset"]
		var unchanged := is_equal_approx(scale, 1.0) and offset.is_equal_approx(Vector2(bbox.position))
		if unchanged:
			continue

		var cx := idx % cols
		var cy := idx / cols
		var cell_origin := Vector2i(cx * fw, cy * fh)

		var content_rect := Rect2i(cell_origin + bbox.position, bbox.size)
		var content_img := original.get_region(content_rect)

		var scaled_w: int = max(1, int(round(bbox.size.x * scale)))
		var scaled_h: int = max(1, int(round(bbox.size.y * scale)))
		content_img.resize(scaled_w, scaled_h, Image.INTERPOLATE_LANCZOS)

		out_image.fill_rect(Rect2i(cell_origin, Vector2i(fw, fh)), Color(0, 0, 0, 0))

		var dst_offset: Vector2i = Vector2i(offset.round())
		out_image.blit_rect(content_img, Rect2i(Vector2i.ZERO, content_img.get_size()), cell_origin + dst_offset)

	var tmp_path := abs_path + ".tmp"
	var err: Error = out_image.save_png(tmp_path)
	if err != OK:
		push_warning("echec ecriture png temporaire: " + tmp_path)
		return false
	var rename_err := DirAccess.rename_absolute(tmp_path, abs_path)
	if rename_err != OK:
		push_warning("echec renommage sheet: " + str(rename_err))
		return false
	return true
