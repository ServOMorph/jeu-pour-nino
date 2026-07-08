extends SceneTree

func _initialize() -> void:
	var MainScript := load("res://editeur/main.gd")
	var main: Control = MainScript.new()
	get_root().add_child(main)
	main._ready()
	main._export_entity_specs()

	var spec_path := "res://specs/player.md"
	if not FileAccess.file_exists(spec_path):
		push_error("spec player absente")
		quit(1)
		return

	var content := FileAccess.get_file_as_string(spec_path)
	var expected_snippets := [
		"# player",
		"## Etats",
		"### attack",
		"- sheet: res://assets/sprites/player/player_attack_sheet.png",
		"### run",
		"- target_frame_size: 87x150",
		"- fps: 8.1",
		"- sheet: res://assets/sprites/player/player_run_sheet.png",
		"## Anomalies ouvertes",
		"- aucune"
	]
	for snippet in expected_snippets:
		if not content.contains(snippet):
			push_error("spec incomplete: " + snippet)
			quit(1)
			return

	print("specs_export_ok=true")
	quit(0)
