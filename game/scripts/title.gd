extends Control

enum State { MAIN, DEV }

const COLOR_SELECTED  := Color(1.0, 1.0, 1.0)
const COLOR_IDLE      := Color(0.45, 0.45, 0.45)
const COLOR_TOGGLE_ON := Color(0.4, 1.0, 0.4)

var _state    := State.MAIN
var _selected := 0
var _dev_res  := false
var _started  := false
var _a_was    := true

var _main_root:   Control
var _dev_root:    Control
var _main_labels: Array[Label] = []
var _dev_labels:  Array[Label] = []

const MAIN_ENTRIES := ["JOUER", "MODE DEV"]
const DEV_ENTRIES  := ["[ ] 100 MIN", "JOUER", "ATELIER", "TEST BOSS", "RETOUR"]

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.10)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var title := Label.new()
	title.text = "CoreDive Challenge"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.7, 0.4, 0.9))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 60)
	title.size = Vector2(480, 36)
	add_child(title)

	var sub := Label.new()
	sub.text = "Sauras-tu atteindre le Noyau ?"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 11)
	sub.position = Vector2(0, 100)
	sub.size = Vector2(480, 20)
	add_child(sub)

	_build_main_menu()
	_build_dev_menu()

	var hint_pad := Label.new()
	hint_pad.text = "Manette : stick gauche bouger   A sauter   RB attaquer"
	hint_pad.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_pad.add_theme_font_size_override("font_size", 9)
	hint_pad.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	hint_pad.position = Vector2(0, 230)
	hint_pad.size = Vector2(480, 16)
	add_child(hint_pad)

	_show_main()

func _build_main_menu() -> void:
	_main_root = Control.new()
	add_child(_main_root)
	for i in MAIN_ENTRIES.size():
		var lbl := Label.new()
		lbl.text = MAIN_ENTRIES[i]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.position = Vector2(0, 148 + i * 26)
		lbl.size = Vector2(480, 22)
		_main_root.add_child(lbl)
		_main_labels.append(lbl)

func _build_dev_menu() -> void:
	_dev_root = Control.new()
	add_child(_dev_root)

	var dev_title := Label.new()
	dev_title.text = "— MODE DEV —"
	dev_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dev_title.add_theme_font_size_override("font_size", 11)
	dev_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	dev_title.position = Vector2(0, 120)
	dev_title.size = Vector2(480, 18)
	_dev_root.add_child(dev_title)

	for i in DEV_ENTRIES.size():
		var lbl := Label.new()
		lbl.text = DEV_ENTRIES[i]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.position = Vector2(0, 144 + i * 26)
		lbl.size = Vector2(480, 22)
		_dev_root.add_child(lbl)
		_dev_labels.append(lbl)

	_dev_root.visible = false

func _show_main() -> void:
	_state = State.MAIN
	_selected = 0
	_main_root.visible = true
	_dev_root.visible = false
	_refresh()

func _show_dev() -> void:
	_state = State.DEV
	_selected = 0
	_main_root.visible = false
	_dev_root.visible = true
	_refresh()

func _refresh() -> void:
	match _state:
		State.MAIN:
			for i in _main_labels.size():
				_main_labels[i].add_theme_color_override("font_color",
					COLOR_SELECTED if i == _selected else COLOR_IDLE)
		State.DEV:
			for i in _dev_labels.size():
				var is_toggle := i == 0
				if is_toggle:
					_dev_labels[i].text = "[X] 100 MIN" if _dev_res else "[ ] 100 MIN"
					var col: Color
					if i == _selected:
						col = COLOR_TOGGLE_ON if _dev_res else COLOR_SELECTED
					else:
						col = COLOR_TOGGLE_ON if _dev_res else COLOR_IDLE
					_dev_labels[i].add_theme_color_override("font_color", col)
				else:
					_dev_labels[i].add_theme_color_override("font_color",
						COLOR_SELECTED if i == _selected else COLOR_IDLE)

func _process(_delta: float) -> void:
	var a := false
	for pad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_A):
			a = true
	var a_just := a and not _a_was
	_a_was = a

	if _started:
		return

	if Input.is_action_just_pressed("ui_down"):
		_selected = (_selected + 1) % _current_size()
		_refresh()
	elif Input.is_action_just_pressed("ui_up"):
		_selected = (_selected - 1 + _current_size()) % _current_size()
		_refresh()

	if Input.is_action_just_pressed("ui_cancel"):
		if _state == State.DEV:
			_show_main()
		return

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") or a_just:
		_confirm()

func _current_size() -> int:
	return MAIN_ENTRIES.size() if _state == State.MAIN else DEV_ENTRIES.size()

func _confirm() -> void:
	match _state:
		State.MAIN:
			match _selected:
				0: _start_game("", 0)
				1: _show_dev()
		State.DEV:
			match _selected:
				0: _dev_res = not _dev_res; _refresh()
				1: _start_game("", 100 if _dev_res else 0)
				2: _start_game("atelier", 100 if _dev_res else 0)
				3: _start_game("boss", 0)
				4: _show_main()

func _start_game(spawn: String, resources: int) -> void:
	if _started:
		return
	_started = true
	Dev.spawn = spawn
	Dev.dev_resources = resources
	get_tree().change_scene_to_file("res://scenes/levels/biome1.tscn")
