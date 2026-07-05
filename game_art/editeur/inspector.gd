extends VBoxContainer

signal state_edited(entity: String, state: String, cfg: Dictionary)

var _entity := ""
var _state := ""
var _cfg: Dictionary = {}
var _driver_ref: AnimatedSprite2D

var _frames_list: ItemList
var _add_index_spin: SpinBox
var _offset_x: SpinBox
var _offset_y: SpinBox
var _frame_size_x: SpinBox
var _frame_size_y: SpinBox

const NARROW_SPIN_WIDTH := 58.0

func setup(entity: String, state: String, cfg: Dictionary, driver_ref: AnimatedSprite2D) -> void:
	_entity = entity
	_state = state
	_cfg = cfg
	_driver_ref = driver_ref
	_rebuild()

func _rebuild() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for child in get_children():
		child.queue_free()

	var lbl := Label.new()
	lbl.text = "%s / %s" % [_entity, _state]
	add_child(lbl)

	_build_fps_row()
	_build_loop_row()
	_build_offset_row()

	var is_sheet := String(_cfg.get("sheet", "")) != ""
	if is_sheet:
		_build_frame_size_row()

	_build_frames_section(is_sheet)

func _build_fps_row() -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(row)
	var lbl := Label.new()
	lbl.text = "FPS"
	row.add_child(lbl)
	var spin := SpinBox.new()
	spin.custom_minimum_size = Vector2(NARROW_SPIN_WIDTH, 0)
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spin.min_value = 0.1
	spin.max_value = 60.0
	spin.step = 0.5
	spin.value = float(_cfg.get("fps", 1.0))
	spin.value_changed.connect(_on_fps_changed)
	row.add_child(spin)

func _on_fps_changed(value: float) -> void:
	_cfg["fps"] = value
	_emit_edited()

func _build_loop_row() -> void:
	var check := CheckBox.new()
	check.text = "Loop"
	check.button_pressed = bool(_cfg.get("loop", true))
	check.toggled.connect(_on_loop_toggled)
	add_child(check)

func _on_loop_toggled(pressed: bool) -> void:
	_cfg["loop"] = pressed
	_emit_edited()

func _build_offset_row() -> void:
	var lbl := Label.new()
	lbl.text = "Offset"
	add_child(lbl)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(row)

	var offset: Variant = _cfg.get("offset", [0.0, 0.0])
	var ox := float(offset[0]) if offset is Array and offset.size() >= 2 else 0.0
	var oy := float(offset[1]) if offset is Array and offset.size() >= 2 else 0.0

	_offset_x = SpinBox.new()
	_offset_x.custom_minimum_size = Vector2(NARROW_SPIN_WIDTH, 0)
	_offset_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_offset_x.min_value = -128
	_offset_x.max_value = 128
	_offset_x.step = 1.0
	_offset_x.value = ox
	_offset_x.value_changed.connect(_on_offset_changed)
	row.add_child(_offset_x)

	_offset_y = SpinBox.new()
	_offset_y.custom_minimum_size = Vector2(NARROW_SPIN_WIDTH, 0)
	_offset_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_offset_y.min_value = -128
	_offset_y.max_value = 128
	_offset_y.step = 1.0
	_offset_y.value = oy
	_offset_y.value_changed.connect(_on_offset_changed)
	row.add_child(_offset_y)

func _on_offset_changed(_value: float) -> void:
	_cfg["offset"] = [_offset_x.value, _offset_y.value]
	_emit_edited()

func _build_frame_size_row() -> void:
	var lbl := Label.new()
	lbl.text = "Taille frame"
	add_child(lbl)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(row)

	var fsz: Variant = _cfg.get("frame_size", [16, 16])
	var fw := int(fsz[0]) if fsz is Array and fsz.size() >= 2 else 16
	var fh := int(fsz[1]) if fsz is Array and fsz.size() >= 2 else 16

	_frame_size_x = SpinBox.new()
	_frame_size_x.custom_minimum_size = Vector2(NARROW_SPIN_WIDTH, 0)
	_frame_size_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_frame_size_x.min_value = 1
	_frame_size_x.max_value = 512
	_frame_size_x.step = 1
	_frame_size_x.value = fw
	_frame_size_x.value_changed.connect(_on_frame_size_changed)
	row.add_child(_frame_size_x)

	_frame_size_y = SpinBox.new()
	_frame_size_y.custom_minimum_size = Vector2(NARROW_SPIN_WIDTH, 0)
	_frame_size_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_frame_size_y.min_value = 1
	_frame_size_y.max_value = 512
	_frame_size_y.step = 1
	_frame_size_y.value = fh
	_frame_size_y.value_changed.connect(_on_frame_size_changed)
	row.add_child(_frame_size_y)

func _on_frame_size_changed(_value: float) -> void:
	_cfg["frame_size"] = [int(_frame_size_x.value), int(_frame_size_y.value)]
	_emit_edited()
	_rebuild()

func _build_frames_section(is_sheet: bool) -> void:
	var lbl := Label.new()
	lbl.text = "Frames"
	add_child(lbl)

	_frames_list = ItemList.new()
	_frames_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_frames_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_frames_list)

	var frames: Variant = _cfg.get("frames", [])
	if frames is Array:
		for f in frames:
			var value := str(f)
			_frames_list.add_item(_format_frame_label(value))
			_frames_list.set_item_tooltip(_frames_list.item_count - 1, value)

	var btn_col := VBoxContainer.new()
	btn_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(btn_col)

	var btn_up := Button.new()
	btn_up.text = "Monter"
	btn_up.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_up.pressed.connect(_move_frame.bind(-1))
	btn_col.add_child(btn_up)

	var btn_down := Button.new()
	btn_down.text = "Descendre"
	btn_down.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_down.pressed.connect(_move_frame.bind(1))
	btn_col.add_child(btn_down)

	var btn_remove := Button.new()
	btn_remove.text = "Retirer"
	btn_remove.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_remove.pressed.connect(_remove_frame)
	btn_col.add_child(btn_remove)

	if is_sheet:
		var add_row := HBoxContainer.new()
		add_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(add_row)

		_add_index_spin = SpinBox.new()
		_add_index_spin.custom_minimum_size = Vector2(NARROW_SPIN_WIDTH, 0)
		_add_index_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_add_index_spin.min_value = 0
		var bound := 0
		if _driver_ref != null and _driver_ref.has_method("get_sheet_frame_count"):
			bound = max(_driver_ref.get_sheet_frame_count(String(_cfg.get("sheet", "")), _cfg.get("frame_size", [16, 16])) - 1, 0)
		_add_index_spin.max_value = bound
		_add_index_spin.step = 1
		add_row.add_child(_add_index_spin)

		var btn_add := Button.new()
		btn_add.text = "Ajouter"
		btn_add.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_add.pressed.connect(_add_frame)
		add_row.add_child(btn_add)

func _format_frame_label(value: String) -> String:
	if value.begins_with("res://"):
		return value.get_file()
	return value

func _move_frame(delta: int) -> void:
	var selected := _frames_list.get_selected_items()
	if selected.is_empty():
		return
	var i := selected[0]
	var j := i + delta
	var frames: Array = _cfg.get("frames", [])
	if j < 0 or j >= frames.size():
		return
	var tmp = frames[i]
	frames[i] = frames[j]
	frames[j] = tmp
	_cfg["frames"] = frames
	_emit_edited()
	_rebuild()
	_frames_list.select(j)

func _remove_frame() -> void:
	var selected := _frames_list.get_selected_items()
	if selected.is_empty():
		return
	var frames: Array = _cfg.get("frames", [])
	frames.remove_at(selected[0])
	_cfg["frames"] = frames
	_emit_edited()
	_rebuild()

func _add_frame() -> void:
	var frames: Array = _cfg.get("frames", [])
	frames.append(int(_add_index_spin.value))
	_cfg["frames"] = frames
	_emit_edited()
	_rebuild()

func _emit_edited() -> void:
	state_edited.emit(_entity, _state, _cfg)
