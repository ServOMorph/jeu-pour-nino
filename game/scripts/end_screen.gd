extends CanvasLayer

# Ecran de fin (game over / victoire). Tourne en PROCESS_MODE_ALWAYS pour
# rester actif pendant get_tree().paused. La navigation manette utilise le
# polling de l'Input singleton (meme approche que title.gd, prouvee fiable),
# car _input()/ui_accept ne se declenchent pas de facon fiable durant la pause.

var _buttons: Array[Button] = []
var _focus := 0

# Edge detection manette
var _a_was := false
var _down_was := false
var _up_was := false

func setup(message: String, color: Color, victory: bool, pc_gained: int = 0) -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 40)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	var title := Label.new()
	title.text = message
	title.add_theme_color_override("font_color", color)
	title.add_theme_font_size_override("font_size", 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var pc_label := Label.new()
	pc_label.text = "+%d PC" % pc_gained
	pc_label.add_theme_color_override("font_color", Color(0.9, 0.78, 0.45))
	pc_label.add_theme_font_size_override("font_size", 44)
	pc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pc_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 56)
	vbox.add_child(spacer)

	var retry := Button.new()
	retry.text = "REESSAYER" if not victory else "REJOUER"
	retry.custom_minimum_size = Vector2(800, 136)
	vbox.add_child(retry)
	retry.pressed.connect(_on_retry)
	_buttons.append(retry)

	var menu := Button.new()
	menu.text = "MENU"
	menu.custom_minimum_size = Vector2(800, 136)
	vbox.add_child(menu)
	menu.pressed.connect(_on_menu)
	_buttons.append(menu)

	if not victory:
		var quit := Button.new()
		quit.text = "FERMER LE JEU"
		quit.custom_minimum_size = Vector2(800, 136)
		vbox.add_child(quit)
		quit.pressed.connect(_on_quit)
		_buttons.append(quit)

	_focus = 0
	_buttons[0].grab_focus()

func _process(_delta: float) -> void:
	# --- Manette : polling direct (fiable pendant la pause) ---
	var a := false
	var down := false
	var up := false
	for pad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_A):
			a = true
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_DPAD_DOWN) \
				or Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y) > 0.5:
			down = true
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_DPAD_UP) \
				or Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y) < -0.5:
			up = true

	# --- Clavier (en plus) ---
	if Input.is_action_just_pressed("ui_down"):
		down = true and not _down_was
	if Input.is_action_just_pressed("ui_up"):
		up = true and not _up_was
	if Input.is_action_just_pressed("ui_accept"):
		_activate()

	if down and not _down_was:
		_move_focus(1)
	if up and not _up_was:
		_move_focus(-1)
	if a and not _a_was:
		_activate()

	_a_was = a
	_down_was = down
	_up_was = up

func _move_focus(delta: int) -> void:
	_focus = (_focus + delta + _buttons.size()) % _buttons.size()
	_buttons[_focus].grab_focus()

func _activate() -> void:
	_buttons[_focus].pressed.emit()

func _on_retry() -> void:
	GameFlow.start_run()
	GameFlow.return_to_hub()

func _on_menu() -> void:
	GameFlow.return_to_title()

func _on_quit() -> void:
	get_tree().quit()
