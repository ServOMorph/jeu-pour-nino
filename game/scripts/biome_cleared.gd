extends CanvasLayer

signal finished

const DISPLAY_TIME := 2.2

var _label: Label

func setup(biome_name: String) -> void:
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
	vbox.add_theme_constant_override("separation", 32)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "BOSS VAINCU"
	title.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	title.add_theme_font_size_override("font_size", 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_label = Label.new()
	_label.text = "%s - retour au HUB" % biome_name
	_label.add_theme_font_size_override("font_size", 44)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_label)

	await get_tree().create_timer(DISPLAY_TIME).timeout
	finished.emit()
