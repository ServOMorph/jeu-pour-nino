extends Control

const SAVE_PATH := "d:/ServOMorph/Jeu pour Nino/game/calibration_result.json"
const AXIS_DEAD := 0.4

const STEPS: Array = [
	{"name": "A",             "type": "button"},
	{"name": "B",             "type": "button"},
	{"name": "X",             "type": "button"},
	{"name": "Y",             "type": "button"},
	{"name": "LB",            "type": "button"},
	{"name": "RB",            "type": "button"},
	{"name": "ZL",            "type": "button_or_axis"},
	{"name": "ZR",            "type": "button_or_axis"},
	{"name": "Start",         "type": "button"},
	{"name": "Select",        "type": "button"},
	{"name": "L stick clic",  "type": "button"},
	{"name": "R stick clic",  "type": "button"},
	{"name": "Croix haut",    "type": "button_or_axis"},
	{"name": "Croix bas",     "type": "button_or_axis"},
	{"name": "Croix gauche",  "type": "button_or_axis"},
	{"name": "Croix droite",  "type": "button_or_axis"},
	{"name": "Stick gauche X","type": "axis"},
	{"name": "Stick gauche Y","type": "axis"},
	{"name": "Stick droit X", "type": "axis"},
	{"name": "Stick droit Y", "type": "axis"},
]

var _step := 0
var _results := {}
var _prev_buttons := {}
var _prev_axes := {}
var _wait_frames := 0  # attend que le bouton soit relache avant de passer

var _pad_label: Label
var _prompt: Label
var _done: Label
var _progress: Label

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	add_child(bg)

	_pad_label = Label.new()
	_pad_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pad_label.add_theme_font_size_override("font_size", 8)
	_pad_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	_pad_label.position = Vector2(0, 10); _pad_label.size = Vector2(480, 16)
	add_child(_pad_label)

	_progress = Label.new()
	_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress.add_theme_font_size_override("font_size", 9)
	_progress.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	_progress.position = Vector2(0, 80); _progress.size = Vector2(480, 20)
	add_child(_progress)

	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 18)
	_prompt.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	_prompt.position = Vector2(0, 110); _prompt.size = Vector2(480, 36)
	add_child(_prompt)

	_done = Label.new()
	_done.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_done.add_theme_font_size_override("font_size", 10)
	_done.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	_done.position = Vector2(0, 180); _done.size = Vector2(480, 60)
	add_child(_done)

func _process(_delta: float) -> void:
	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		_prompt.text = "Branche la manette..."
		return
	var pad: int = pads[0]
	_pad_label.text = "%s  |  GUID: %s" % [Input.get_joy_name(pad), Input.get_joy_guid(pad)]

	if _step >= STEPS.size():
		return

	_wait_frames = max(0, _wait_frames - 1)
	if _wait_frames > 0:
		return

	var step: Dictionary = STEPS[_step]
	_progress.text = "Etape %d / %d" % [_step + 1, STEPS.size()]
	_prompt.text = "Appuie sur :  %s" % step["name"]

	# Detection
	for b in range(24):
		if Input.is_joy_button_pressed(pad, b) and not _prev_buttons.get(b, false):
			_record(step["name"], {"type": "button", "index": b})
			_next()
			break

	if _step < STEPS.size() and (step["type"] == "axis" or step["type"] == "button_or_axis"):
		for a in range(8):
			var v := Input.get_joy_axis(pad, a)
			if absf(v) > AXIS_DEAD and absf(_prev_axes.get(a, 0.0)) <= AXIS_DEAD:
				_record(step["name"], {"type": "axis", "index": a, "direction": signf(v)})
				_next()
				break

	# Mise a jour etat precedent
	for b in range(24):
		_prev_buttons[b] = Input.is_joy_button_pressed(pad, b)
	for a in range(8):
		_prev_axes[a] = Input.get_joy_axis(pad, a)

func _record(name: String, data: Dictionary) -> void:
	_results[name] = data
	_done.text = ""
	for k in _results:
		var d: Dictionary = _results[k]
		if d["type"] == "button":
			_done.text += "%s → bouton %d\n" % [k, d["index"]]
		else:
			_done.text += "%s → axe %d (dir %+.0f)\n" % [k, d["index"], d["direction"]]

func _next() -> void:
	_step += 1
	_wait_frames = 10
	if _step >= STEPS.size():
		_save()
		_prompt.text = "Calibration terminee !"
		_progress.text = "Ferme le jeu, je lis le fichier."

func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_results, "\t"))
		f.close()
