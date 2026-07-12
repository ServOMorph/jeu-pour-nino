extends Control
class_name SheetEditorCanvas

signal transform_changed(idx: int)

enum DragMode { NONE, MOVE, RESIZE }

const HANDLE_SIZE := 8.0
const MIN_SCALE := 0.1
const MAX_FIT_ZOOM := 16.0

var _sheet_image: Image
var _sheet_texture: ImageTexture
var _frame_size := Vector2i(16, 16)
var _cols := 1
var _rows := 1
var _editable_indices: Dictionary = {}
var _frame_edits: Dictionary = {}
var _selected_idx := -1
var _zoom := 4.0

var _drag_mode := DragMode.NONE
var _drag_start_mouse := Vector2.ZERO
var _drag_start_offset := Vector2.ZERO
var _drag_start_scale := 1.0

func setup(sheet_image: Image, frame_size: Vector2i, editable_indices: Array) -> void:
	_sheet_image = sheet_image
	_sheet_texture = ImageTexture.create_from_image(sheet_image)
	_frame_size = frame_size
	_cols = max(1, sheet_image.get_width() / max(1, frame_size.x))
	_rows = max(1, sheet_image.get_height() / max(1, frame_size.y))
	_editable_indices.clear()
	_frame_edits.clear()
	_selected_idx = -1

	for raw_idx in editable_indices:
		var idx := int(raw_idx)
		_editable_indices[idx] = true
		var cx := idx % _cols
		var cy := idx / _cols
		var cell_img := _sheet_image.get_region(Rect2i(cx * _frame_size.x, cy * _frame_size.y, _frame_size.x, _frame_size.y))
		var bbox := cell_img.get_used_rect()
		if bbox.size == Vector2i.ZERO:
			continue
		_frame_edits[idx] = {
			"bbox": bbox,
			"scale": 1.0,
			"offset": Vector2(bbox.position),
		}

	custom_minimum_size = Vector2(_sheet_image.get_size()) * _zoom
	queue_redraw()

func fit_to(available_size: Vector2) -> void:
	if _sheet_image == null:
		return
	var sheet_size := Vector2(_sheet_image.get_size())
	if sheet_size.x <= 0.0 or sheet_size.y <= 0.0:
		return
	var fit_zoom: float = minf(available_size.x / sheet_size.x, available_size.y / sheet_size.y)
	_zoom = clampf(fit_zoom, 0.1, MAX_FIT_ZOOM)
	custom_minimum_size = sheet_size * _zoom
	queue_redraw()

func get_frame_edits() -> Dictionary:
	return _frame_edits

func get_editable_indices() -> Dictionary:
	return _editable_indices

func get_cols() -> int:
	return _cols

func get_frame_size() -> Vector2i:
	return _frame_size

func set_frame_transform(idx: int, scale: float, offset: Vector2) -> void:
	if not _frame_edits.has(idx):
		return
	var edit: Dictionary = _frame_edits[idx]
	var bbox: Rect2i = edit["bbox"]
	var max_scale := _max_scale_for(bbox)
	var new_scale := clampf(scale, MIN_SCALE, max_scale)
	var scaled := Vector2(bbox.size) * new_scale
	var new_offset := Vector2(
		clampf(offset.x, 0.0, max(0.0, _frame_size.x - scaled.x)),
		clampf(offset.y, 0.0, max(0.0, _frame_size.y - scaled.y))
	)
	edit["scale"] = new_scale
	edit["offset"] = new_offset
	_frame_edits[idx] = edit
	transform_changed.emit(idx)
	queue_redraw()

func _max_scale_for(bbox: Rect2i) -> float:
	if bbox.size.x <= 0 or bbox.size.y <= 0:
		return 1.0
	return minf(float(_frame_size.x) / bbox.size.x, float(_frame_size.y) / bbox.size.y)

func _content_rect_sheet(idx: int) -> Rect2:
	var edit: Dictionary = _frame_edits[idx]
	var bbox: Rect2i = edit["bbox"]
	var cx := idx % _cols
	var cy := idx / _cols
	var cell_origin := Vector2(cx * _frame_size.x, cy * _frame_size.y)
	var scale: float = edit["scale"]
	var offset: Vector2 = edit["offset"]
	return Rect2(cell_origin + offset, Vector2(bbox.size) * scale)

func _cell_rect_screen(idx: int) -> Rect2:
	var cx := idx % _cols
	var cy := idx / _cols
	return Rect2(Vector2(cx * _frame_size.x, cy * _frame_size.y) * _zoom, Vector2(_frame_size) * _zoom)

func _source_rect_sheet(idx: int) -> Rect2:
	var edit: Dictionary = _frame_edits[idx]
	var bbox: Rect2i = edit["bbox"]
	var cx := idx % _cols
	var cy := idx / _cols
	var cell_origin := Vector2(cx * _frame_size.x, cy * _frame_size.y)
	return Rect2(cell_origin + Vector2(bbox.position), Vector2(bbox.size))

func _draw() -> void:
	if _sheet_texture == null:
		return
	draw_texture_rect(_sheet_texture, Rect2(Vector2.ZERO, Vector2(_sheet_image.get_size()) * _zoom), false)

	for gx in range(_cols + 1):
		var x := gx * _frame_size.x * _zoom
		draw_line(Vector2(x, 0), Vector2(x, _rows * _frame_size.y * _zoom), Color(1, 1, 1, 0.25))
	for gy in range(_rows + 1):
		var y := gy * _frame_size.y * _zoom
		draw_line(Vector2(0, y), Vector2(_cols * _frame_size.x * _zoom, y), Color(1, 1, 1, 0.25))

	for idx in range(_cols * _rows):
		var cell_rect := _cell_rect_screen(idx)
		if not _editable_indices.has(idx):
			draw_rect(cell_rect, Color(0, 0, 0, 0.35))
		elif _frame_edits.has(idx):
			# efface le contenu original de la case puis redessine la frame a sa transformation courante (aperçu temps reel)
			draw_rect(cell_rect, Color(0.1, 0.1, 0.1, 1.0), true)
			var content_rect := _content_rect_sheet(idx)
			var content_screen := Rect2(content_rect.position * _zoom, content_rect.size * _zoom)
			draw_texture_rect_region(_sheet_texture, content_screen, _source_rect_sheet(idx))
			draw_rect(cell_rect, Color(0.3, 0.9, 0.3, 1.0), false, 1.0)

	if _selected_idx >= 0 and _frame_edits.has(_selected_idx):
		var content_rect := _content_rect_sheet(_selected_idx)
		var content_screen := Rect2(content_rect.position * _zoom, content_rect.size * _zoom)
		draw_rect(content_screen, Color(1, 0.9, 0.2, 1.0), false, 2.0)
		var handle_rect := Rect2(content_screen.end - Vector2(HANDLE_SIZE, HANDLE_SIZE), Vector2(HANDLE_SIZE, HANDLE_SIZE))
		draw_rect(handle_rect, Color(1, 0.9, 0.2, 1.0), true)

func _cell_index_at(screen_pos: Vector2) -> int:
	var sheet_pos := screen_pos / _zoom
	var cx := int(sheet_pos.x / _frame_size.x)
	var cy := int(sheet_pos.y / _frame_size.y)
	if cx < 0 or cy < 0 or cx >= _cols or cy >= _rows:
		return -1
	return cy * _cols + cx

func _handle_rect_screen(idx: int) -> Rect2:
	var content_rect := _content_rect_sheet(idx)
	var content_screen := Rect2(content_rect.position * _zoom, content_rect.size * _zoom)
	return Rect2(content_screen.end - Vector2(HANDLE_SIZE, HANDLE_SIZE), Vector2(HANDLE_SIZE, HANDLE_SIZE))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_on_mouse_pressed(mb.position)
			else:
				_drag_mode = DragMode.NONE
	elif event is InputEventMouseMotion:
		if _drag_mode != DragMode.NONE:
			_on_mouse_dragged((event as InputEventMouseMotion).position)

func _on_mouse_pressed(pos: Vector2) -> void:
	var idx := _cell_index_at(pos)
	if idx < 0 or not _editable_indices.has(idx) or not _frame_edits.has(idx):
		return

	if idx == _selected_idx and _handle_rect_screen(idx).has_point(pos):
		_drag_mode = DragMode.RESIZE
		_drag_start_mouse = pos
		_drag_start_scale = float(_frame_edits[idx]["scale"])
		return

	var content_rect := _content_rect_sheet(idx)
	var content_screen := Rect2(content_rect.position * _zoom, content_rect.size * _zoom)
	_selected_idx = idx
	if content_screen.has_point(pos):
		_drag_mode = DragMode.MOVE
		_drag_start_mouse = pos
		_drag_start_offset = _frame_edits[idx]["offset"]
	else:
		_drag_mode = DragMode.NONE
	queue_redraw()

func _on_mouse_dragged(pos: Vector2) -> void:
	if _selected_idx < 0 or not _frame_edits.has(_selected_idx):
		return
	var idx := _selected_idx
	var edit: Dictionary = _frame_edits[idx]
	var bbox: Rect2i = edit["bbox"]

	if _drag_mode == DragMode.MOVE:
		var delta_sheet := (pos - _drag_start_mouse) / _zoom
		var new_offset := _drag_start_offset + delta_sheet
		var scaled := Vector2(bbox.size) * float(edit["scale"])
		new_offset.x = clampf(new_offset.x, 0.0, max(0.0, _frame_size.x - scaled.x))
		new_offset.y = clampf(new_offset.y, 0.0, max(0.0, _frame_size.y - scaled.y))
		edit["offset"] = new_offset
	elif _drag_mode == DragMode.RESIZE:
		var cx := idx % _cols
		var cy := idx / _cols
		var anchor := Vector2(cx * _frame_size.x, cy * _frame_size.y) * _zoom
		var dist_start := (_drag_start_mouse - anchor).length()
		var dist_now := (pos - anchor).length()
		var factor: float = dist_now / maxf(dist_start, 0.001)
		var max_scale := _max_scale_for(bbox)
		var new_scale := clampf(_drag_start_scale * factor, MIN_SCALE, max_scale)
		edit["scale"] = new_scale
		var scaled := Vector2(bbox.size) * new_scale
		var offset: Vector2 = edit["offset"]
		offset.x = clampf(offset.x, 0.0, max(0.0, _frame_size.x - scaled.x))
		offset.y = clampf(offset.y, 0.0, max(0.0, _frame_size.y - scaled.y))
		edit["offset"] = offset

	_frame_edits[idx] = edit
	transform_changed.emit(idx)
	queue_redraw()
