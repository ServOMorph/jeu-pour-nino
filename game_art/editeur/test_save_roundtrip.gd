extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var mode := args[0] if args.size() > 0 else "mutate"

	if mode == "mutate":
		_run_mutate()
	elif mode == "verify":
		_run_verify()
	elif mode == "normalize":
		_run_normalize()
	else:
		push_error("mode inconnu: " + mode)
		quit(1)

func _run_normalize() -> void:
	var MainScript := load("res://editeur/main.gd")
	var main: Control = MainScript.new()
	main._build_ui()
	main._load_entities()
	main._save()
	print("NORMALISATION terminee")
	quit(0)

func _run_mutate() -> void:
	var MainScript := load("res://editeur/main.gd")
	var main: Control = MainScript.new()
	main._build_ui()
	main._load_entities()

	var entity_idx := _find_item_index(main._entity_list, "player")
	if entity_idx < 0:
		push_error("entite player introuvable")
		quit(1)
		return
	main._on_entity_selected(entity_idx)

	var state_idx := _find_item_index(main._state_list, "run")
	if state_idx < 0:
		push_error("etat run introuvable")
		quit(1)
		return
	main._on_state_selected(state_idx)

	var before: float = main._inspector._cfg.get("fps", 0.0)
	print("AVANT fps=", before)

	main._inspector._on_fps_changed(4.0)
	main._save()

	var after: float = main._entities["player"]["states"]["run"]["fps"]
	print("APRES(memoire) fps=", after)
	quit(0 if after == 4.0 else 1)

func _run_verify() -> void:
	var file := FileAccess.open("res://data/animations.json", FileAccess.READ)
	if file == null:
		push_error("lecture impossible")
		quit(1)
		return
	var parsed: Dictionary = JSON.parse_string(file.get_as_text())
	var run_fps: float = parsed["player"]["states"]["run"]["fps"]
	var idle_frames: Variant = parsed["player"]["states"]["idle"].get("frames", null)
	print("DISQUE run.fps=", run_fps)
	print("DISQUE idle.frames=", idle_frames)
	var ok: bool = run_fps == 4.0 and idle_frames is Array and idle_frames.size() > 0 and idle_frames[0] is String
	quit(0 if ok else 1)

func _find_item_index(list: ItemList, text: String) -> int:
	for i in list.item_count:
		if list.get_item_text(i) == text:
			return i
	return -1
