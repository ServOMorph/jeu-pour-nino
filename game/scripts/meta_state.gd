extends Node

var skill_points := 0
var grimoire: Dictionary = {}

func reset_for_new_game() -> void:
	skill_points = 0
	grimoire.clear()

func add_skill_points(amount: int) -> void:
	skill_points += amount

func spend_skill_points(amount: int) -> bool:
	if skill_points < amount:
		return false
	skill_points -= amount
	return true

func discover_recipe(id: String) -> void:
	if id not in grimoire:
		grimoire[id] = {"discovered": true, "mastered": false}

func master_recipe(id: String) -> bool:
	if id not in grimoire:
		return false
	grimoire[id]["mastered"] = true
	return true

func is_discovered(id: String) -> bool:
	return id in grimoire

func is_mastered(id: String) -> bool:
	if id not in grimoire:
		return false
	return bool(grimoire[id].get("mastered", false))

func serialize() -> Dictionary:
	return {
		"skill_points": skill_points,
		"grimoire": grimoire.duplicate(true),
	}

func deserialize(data: Dictionary) -> void:
	skill_points = int(data.get("skill_points", 0))
	grimoire = data.get("grimoire", {}).duplicate(true)
