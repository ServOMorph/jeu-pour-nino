extends RefCounted
class_name Progression

const CONFIG := "res://data/progression.json"

static func load_bareme() -> Dictionary:
	var file := FileAccess.open(CONFIG, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

static func compute_skill_points(counters: Dictionary, bareme: Dictionary) -> int:
	var total := 0.0
	total += float(counters.get("biomes_visited", 0)) * float(bareme.get("biome_visited", 0))
	total += float(counters.get("secret_rooms", 0)) * float(bareme.get("secret_room", 0))
	total += float(counters.get("elites_defeated", 0)) * float(bareme.get("elite_defeated", 0))
	total += float(counters.get("bosses_defeated", 0)) * float(bareme.get("boss_defeated", 0))
	total += float(counters.get("resurrections", 0)) * float(bareme.get("resurrection_success", 0))
	if bool(counters.get("victory", false)):
		total += float(bareme.get("victory_bonus", 0))
	if bool(counters.get("run_failed", false)):
		total *= float(bareme.get("failure_multiplier", 1.0))
	return int(round(total))
