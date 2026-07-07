extends SceneTree

func _initialize() -> void:
	var MainScript := load("res://editeur/main.gd")
	var main: Control = MainScript.new()
	get_root().add_child(main)
	main._ready()
	main.size = Vector2(1400, 900)
	main._update_preview_size()
	await process_frame
	await process_frame

	main._select_entity_and_state("player", "idle")
	await process_frame
	await process_frame

	var texture: Texture2D = main._driver.sprite_frames.get_frame_texture(main._driver.animation, main._driver.frame)
	var expected_position: Vector2 = (Vector2(main._viewport.size) - texture.get_size()) * 0.5
	if main._driver.position.distance_to(expected_position) > 0.01:
		push_error("preview produit decentre: position=%s attendu=%s" % [main._driver.position, expected_position])
		quit(1)
		return

	print("preview_center_ok=true")
	quit(0)
