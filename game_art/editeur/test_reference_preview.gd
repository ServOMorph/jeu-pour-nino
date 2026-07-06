extends SceneTree

func _initialize() -> void:
	var MainScript := load("res://editeur/main.gd")
	var main: Control = MainScript.new()
	get_root().add_child(main)
	main._ready()

	main._select_entity_and_state("player", "run")
	if main._reference_texture_rect.texture == null:
		push_error("reference player/run absente")
		quit(1)
		return

	if main._preview_container.stretch_shrink != main._reference_preview_container.stretch_shrink:
		push_error("zoom reference non synchronise")
		quit(1)
		return

	main._set_zoom(6.0)
	if main._preview_container.stretch_shrink != 6 or main._reference_preview_container.stretch_shrink != 6:
		push_error("zoom x6 non applique aux deux previews")
		quit(1)
		return

	print("reference_preview_ok=true")
	quit(0)
