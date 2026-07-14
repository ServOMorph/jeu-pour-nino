extends Node

const PROGRESSION := preload("res://scripts/progression.gd")

const HUB_SCENE := "res://scenes/levels/hub.tscn"
const BIOME_SCENE := "res://scenes/levels/biome.tscn"
const TITLE_SCENE := "res://scenes/ui/title.tscn"
const BIOME_CONFIG_DIR := "res://data/biomes/"

var next_biome_id := "biome1"

func start_run(biome_id: String = "biome1") -> void:
	RunState.reset()
	next_biome_id = biome_id

func biome_config_path(biome_id: String) -> String:
	return "%s%s.json" % [BIOME_CONFIG_DIR, biome_id]

func load_biome_config(biome_id: String) -> Dictionary:
	var path := biome_config_path(biome_id)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Config biome introuvable: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_error("Config biome invalide: %s" % path)
	return {}

func enter_biome(biome_id: String) -> void:
	next_biome_id = biome_id
	get_tree().paused = false
	get_tree().change_scene_to_file(BIOME_SCENE)

func return_to_hub() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(HUB_SCENE)

func end_run(failed: bool) -> int:
	if failed:
		RunState.set_counter_flag("run_failed", true)
	var gained := PROGRESSION.compute_skill_points(RunState.get_counters(), PROGRESSION.load_bareme())
	MetaState.add_skill_points(gained)
	SaveManager.save_meta()
	return gained

func return_to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCENE)
