extends SceneTree

const SHEET_ASSET_PATH := "res://assets/test_tmp/sheet_editor_test_sheet.png"
const SHEET_GAME_PATH := "res://assets/sprites/test_tmp/sheet_editor_test_sheet.png"

func _initialize() -> void:
	_prepare_fixture()
	var ok := _run_case()
	_cleanup()
	quit(0 if ok else 1)

func _prepare_fixture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/test_tmp"))
	var img := Image.create(16, 8, false, Image.FORMAT_RGBA8)
	for y in range(2, 6):
		for x in range(2, 6):
			img.set_pixel(x, y, Color(1, 0, 0, 1))
	for y in range(0, 8):
		for x in range(8, 16):
			img.set_pixel(x, y, Color(0, 0, 1, 1))
	img.save_png(ProjectSettings.globalize_path(SHEET_ASSET_PATH))

func _run_case() -> bool:
	var SheetEditorScript := load("res://editeur/sheet_editor.gd")
	var dialog: AcceptDialog = SheetEditorScript.new()
	dialog._build_ui()
	var cfg := {"sheet": SHEET_GAME_PATH, "frame_size": [8, 8], "frames": [0, 1]}
	dialog.open_for("test_entity", "test_state", cfg)

	dialog._canvas.set_frame_transform(0, 0.5, Vector2(0, 0))
	var ok: bool = dialog._apply_and_save()
	if not ok:
		push_error("_apply_and_save a echoue")
		return false

	var result := Image.load_from_file(ProjectSettings.globalize_path(SHEET_ASSET_PATH))
	if result == null:
		push_error("relecture PNG impossible")
		return false
	print("DIMENSIONS=", result.get_size())
	if result.get_size() != Vector2i(16, 8):
		return false

	var px00 := result.get_pixel(0, 0)
	var px_out := result.get_pixel(4, 4)
	print("PX00=", px00, " PX_OUT=", px_out)
	if not px00.is_equal_approx(Color(1, 0, 0, 1)):
		return false
	if px_out.a > 0.01:
		return false

	var px_blue := result.get_pixel(12, 4)
	print("PX_BLUE=", px_blue)
	if not px_blue.is_equal_approx(Color(0, 0, 1, 1)):
		return false

	return true

func _cleanup() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SHEET_ASSET_PATH))
