extends CanvasLayer

signal resume_requested
signal equipment_requested
signal restart_requested
signal title_requested
signal dev_resources_requested
signal dev_hp_requested
signal teleport_requested(spawn_key: String)

enum State { MAIN, DEV }

const COLOR_SELECTED := Color(1.0, 1.0, 1.0)
const COLOR_IDLE := Color(0.45, 0.45, 0.45)
const COLOR_ON := Color(0.4, 1.0, 0.4)

const MAIN_ENTRIES := ["EQUIPEMENT", "REPRENDRE", "RECOMMENCER", "QUITTER", "MODE DEV"]
const DEV_ENTRIES := ["[ ] 100 MAT", "[ ] VIE INF", "ATELIER", "TEST BOSS", "RETOUR"]

var _state := State.MAIN
var _selected := 0
var _open := false
var _main_labels: Array[Label] = []
var _dev_labels: Array[Label] = []
var _main_root: Control
var _dev_root: Control

var _a_was := false
var _b_was := false
var _down_was := false
var _up_was := false

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	hide_menu()

func open_menu() -> void:
	_open = true
	_state = State.MAIN
	_selected = 0
	visible = true
	_refresh()

func hide_menu() -> void:
	_open = false
	visible = false

func is_open() -> bool:
	return _open

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := ColorRect.new()
	panel.color = Color(0.10, 0.08, 0.10)
	panel.position = Vector2(520, 192)
	panel.size = Vector2(880, 704)
	add_child(panel)

	var title := Label.new()
	title.text = "PAUSE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.8, 0.65, 0.35))
	title.position = Vector2(520, 248)
	title.size = Vector2(880, 96)
	add_child(title)

	_main_root = Control.new()
	add_child(_main_root)
	for i in MAIN_ENTRIES.size():
		var lbl := _make_label(MAIN_ENTRIES[i], 408 + i * 96)
		_main_root.add_child(lbl)
		_main_labels.append(lbl)

	_dev_root = Control.new()
	add_child(_dev_root)
	var dev_title := Label.new()
	dev_title.text = "MODE DEV"
	dev_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dev_title.add_theme_font_size_override("font_size", 40)
	dev_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	dev_title.position = Vector2(520, 352)
	dev_title.size = Vector2(880, 72)
	_dev_root.add_child(dev_title)
	for i in DEV_ENTRIES.size():
		var lbl := _make_label(DEV_ENTRIES[i], 432 + i * 88)
		_dev_root.add_child(lbl)
		_dev_labels.append(lbl)

func _make_label(text: String, y: float) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 52)
	lbl.position = Vector2(520, y)
	lbl.size = Vector2(880, 80)
	return lbl

func _process(_delta: float) -> void:
	if not _open:
		return
	var a := Input.is_action_pressed("ui_accept")
	var b := Input.is_action_pressed("ui_cancel")
	var down := Input.is_action_pressed("ui_down")
	var up := Input.is_action_pressed("ui_up")
	for pad in Input.get_connected_joypads():
		a = a or Input.is_joy_button_pressed(pad, JOY_BUTTON_A)
		b = b or Input.is_joy_button_pressed(pad, JOY_BUTTON_B)
		down = down or Input.is_joy_button_pressed(pad, JOY_BUTTON_DPAD_DOWN) or Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y) > 0.5
		up = up or Input.is_joy_button_pressed(pad, JOY_BUTTON_DPAD_UP) or Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y) < -0.5

	if down and not _down_was:
		_selected = (_selected + 1) % _current_size()
		_refresh()
	if up and not _up_was:
		_selected = (_selected - 1 + _current_size()) % _current_size()
		_refresh()
	if b and not _b_was:
		if _state == State.DEV:
			_show_main()
		else:
			resume_requested.emit()
	if a and not _a_was:
		_confirm()

	_a_was = a
	_b_was = b
	_down_was = down
	_up_was = up

func _current_size() -> int:
	return MAIN_ENTRIES.size() if _state == State.MAIN else DEV_ENTRIES.size()

func _show_main() -> void:
	_state = State.MAIN
	_selected = 0
	_refresh()

func _show_dev() -> void:
	_state = State.DEV
	_selected = 0
	_refresh()

func _refresh() -> void:
	_main_root.visible = _state == State.MAIN
	_dev_root.visible = _state == State.DEV
	for i in _main_labels.size():
		_main_labels[i].add_theme_color_override("font_color", COLOR_SELECTED if i == _selected else COLOR_IDLE)
	for i in _dev_labels.size():
		if i == 0:
			_dev_labels[i].text = "[X] 100 MAT" if Dev.dev_resources > 0 else "[ ] 100 MAT"
			_dev_labels[i].add_theme_color_override("font_color", _toggle_color(i, Dev.dev_resources > 0))
		elif i == 1:
			_dev_labels[i].text = "[X] VIE INF" if Dev.infinite_hp else "[ ] VIE INF"
			_dev_labels[i].add_theme_color_override("font_color", _toggle_color(i, Dev.infinite_hp))
		else:
			_dev_labels[i].add_theme_color_override("font_color", COLOR_SELECTED if i == _selected else COLOR_IDLE)

func _toggle_color(index: int, enabled: bool) -> Color:
	if index == _selected:
		return COLOR_ON if enabled else COLOR_SELECTED
	return COLOR_ON if enabled else COLOR_IDLE

func _confirm() -> void:
	if _state == State.MAIN:
		match _selected:
			0:
				equipment_requested.emit()
			1:
				resume_requested.emit()
			2:
				restart_requested.emit()
			3:
				title_requested.emit()
			4:
				_show_dev()
	else:
		match _selected:
			0:
				dev_resources_requested.emit()
				_refresh()
			1:
				dev_hp_requested.emit()
				_refresh()
			2:
				teleport_requested.emit("atelier")
				resume_requested.emit()
			3:
				teleport_requested.emit("boss")
				resume_requested.emit()
			4:
				_show_main()
