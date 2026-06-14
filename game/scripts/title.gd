extends Control

var _started := false

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

	var play := Button.new()
	play.text = "JOUER"
	play.size = Vector2(140, 30)
	play.position = Vector2(170, 150)
	add_child(play)
	play.pressed.connect(_start_game)
	play.grab_focus()

	var hint_kb := Label.new()
	hint_kb.text = "Clavier : Q/D bouger   Espace sauter   Clic gauche attaquer"
	hint_kb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_kb.add_theme_font_size_override("font_size", 9)
	hint_kb.position = Vector2(0, 210)
	hint_kb.size = Vector2(480, 16)
	add_child(hint_kb)

	var hint_pad := Label.new()
	hint_pad.text = "Manette : stick gauche bouger   A sauter   RB attaquer   A lancer"
	hint_pad.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_pad.add_theme_font_size_override("font_size", 9)
	hint_pad.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	hint_pad.position = Vector2(0, 228)
	hint_pad.size = Vector2(480, 16)
	add_child(hint_pad)

func _process(_delta: float) -> void:
	if _started:
		return
	for pad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_A):
			_start_game()
			return

func _start_game() -> void:
	if _started:
		return
	_started = true
	get_tree().change_scene_to_file("res://scenes/levels/biome1.tscn")
