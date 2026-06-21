extends Control

const DEV_SPAWNS := [
	{"key": "", "label": "JOUER", "resources": 0},
	{"key": "", "label": "JOUER 100 MIN", "resources": 100},
	{"key": "boss", "label": "TEST BOSS", "resources": 0},
]

const COLOR_SELECTED := Color(1.0, 1.0, 1.0)
const COLOR_IDLE    := Color(0.45, 0.45, 0.45)

var _started := false
var _selected := 0
var _labels: Array[Label] = []
var _a_was := true

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

	for i in DEV_SPAWNS.size():
		var lbl := Label.new()
		lbl.text = DEV_SPAWNS[i]["label"]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.position = Vector2(0, 148 + i * 26)
		lbl.size = Vector2(480, 22)
		add_child(lbl)
		_labels.append(lbl)

	var hint_kb := Label.new()
	hint_kb.text = "Clavier : Q/D bouger   Espace sauter   Clic gauche attaquer"
	hint_kb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_kb.add_theme_font_size_override("font_size", 9)
	hint_kb.position = Vector2(0, 220)
	hint_kb.size = Vector2(480, 16)
	add_child(hint_kb)

	var hint_pad := Label.new()
	hint_pad.text = "Manette : stick gauche bouger   A sauter   RB attaquer"
	hint_pad.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_pad.add_theme_font_size_override("font_size", 9)
	hint_pad.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	hint_pad.position = Vector2(0, 234)
	hint_pad.size = Vector2(480, 16)
	add_child(hint_pad)

	_refresh_selection()

func _refresh_selection() -> void:
	for i in _labels.size():
		_labels[i].add_theme_color_override("font_color",
			COLOR_SELECTED if i == _selected else COLOR_IDLE)

func _process(_delta: float) -> void:
	if _started:
		return

	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("move_right"):
		_selected = (_selected + 1) % DEV_SPAWNS.size()
		_refresh_selection()
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("move_left"):
		_selected = (_selected - 1 + DEV_SPAWNS.size()) % DEV_SPAWNS.size()
		_refresh_selection()

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		_start_game()
		return

	var a := false
	for pad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_A):
			a = true
	if a and not _a_was:
		_start_game()
	_a_was = a

func _start_game() -> void:
	if _started:
		return
	_started = true
	Dev.spawn = DEV_SPAWNS[_selected]["key"]
	Dev.dev_resources = DEV_SPAWNS[_selected]["resources"]
	get_tree().change_scene_to_file("res://scenes/levels/biome1.tscn")
