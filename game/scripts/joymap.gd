extends Node

# Source unique de verite pour la configuration manette.
# PowerA NSW Wired Controller — GUID 03002d7bd620000019a7000000000000
# Calibre le 2026-06-14. Ne pas editer les indices a la main : relancer calibration.gd.
#
# Layout physique Nintendo : A=droite(b2), B=bas(b1), X=haut(b3), Y=gauche(b0)
# SDL mappe par position donc : a=south=bas. On detourne : a->b2 pour que
# JOY_BUTTON_A = bouton A physique partout dans le jeu.

const POWERA_NSW_GUID := "03002d7bd620000019a7000000000000"

const POWERA_NSW_MAP := (
	POWERA_NSW_GUID + ",PowerA NSW Wired controller,"
	+ "a:b2,"          # A physique (droite)
	+ "b:b1,"          # B physique (bas)
	+ "x:b3,"          # X physique (haut)
	+ "y:b0,"          # Y physique (gauche)
	+ "leftshoulder:b4,"
	+ "rightshoulder:b5,"
	+ "lefttrigger:b6,"
	+ "righttrigger:b7,"
	+ "back:b9,"       # Select / minus
	+ "start:b12,"     # Start / plus
	+ "leftstick:b10,"
	+ "rightstick:b11,"
	+ "dpup:h0.1,"     # D-pad = hat switch sur cette manette
	+ "dpdown:h0.4,"
	+ "dpleft:h0.8,"
	+ "dpright:h0.2,"
	+ "leftx:a0,lefty:a1,"
	+ "rightx:a2,righty:a3,"
	+ "platform:Windows"
)

func _ready() -> void:
	# 1. Injecter le mapping SDL avant toute lecture d'input
	Input.add_joy_mapping(POWERA_NSW_MAP, true)

	# 2. Configurer les actions joypad (complement des bindings clavier/souris
	#    qui restent dans project.godot)
	_setup_input()

func _setup_input() -> void:
	_add_joypad_button("jump",       JOY_BUTTON_A)
	_add_joypad_button("attack",     JOY_BUTTON_RIGHT_SHOULDER)
	_add_joypad_axis("move_left",    JOY_AXIS_LEFT_X, -1.0)
	_add_joypad_axis("move_right",   JOY_AXIS_LEFT_X,  1.0)
	_add_joypad_button("move_left",  JOY_BUTTON_DPAD_LEFT)
	_add_joypad_button("move_right", JOY_BUTTON_DPAD_RIGHT)

# --- helpers ---

func _add_joypad_button(action: String, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		return
	# Evite les doublons
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton and ev.button_index == button:
			return
	var e := InputEventJoypadButton.new()
	e.device = -1  # -1 = toutes les manettes
	e.button_index = button
	InputMap.action_add_event(action, e)

func _add_joypad_axis(action: String, axis: JoyAxis, direction: float) -> void:
	if not InputMap.has_action(action):
		return
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadMotion and ev.axis == axis and signf(ev.axis_value) == signf(direction):
			return
	var e := InputEventJoypadMotion.new()
	e.device = -1
	e.axis = axis
	e.axis_value = direction
	InputMap.action_add_event(action, e)
