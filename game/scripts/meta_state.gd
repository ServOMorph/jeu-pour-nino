extends Node

signal skill_points_changed(total: int)
signal grimoire_changed(id: String)

var skill_points := 0
var grimoire: Dictionary = {}

func reset_for_new_game() -> void:
	skill_points = 0
	grimoire.clear()
	skill_points_changed.emit(skill_points)
	grimoire_changed.emit("")

func add_skill_points(amount: int) -> void:
	skill_points += amount
	skill_points_changed.emit(skill_points)

func grant_dev_skill_points(amount: int) -> void:
	skill_points = amount
	skill_points_changed.emit(skill_points)

func spend_skill_points(amount: int) -> bool:
	if skill_points < amount:
		return false
	skill_points -= amount
	skill_points_changed.emit(skill_points)
	return true

func discover_recipe(id: String) -> void:
	if id not in grimoire:
		grimoire[id] = {"discovered": true, "mastered": false}
		grimoire_changed.emit(id)

func ensure_recipe(id: String, mastered: bool = false) -> void:
	if id.is_empty():
		return
	if id not in grimoire:
		grimoire[id] = {"discovered": true, "mastered": false}
	if mastered:
		grimoire[id]["mastered"] = true
	grimoire_changed.emit(id)

func master_recipe(id: String, cost: int) -> bool:
	if id not in grimoire:
		return false
	if bool(grimoire[id].get("mastered", false)):
		return true
	if not spend_skill_points(cost):
		return false
	grimoire[id]["mastered"] = true
	grimoire_changed.emit(id)
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
	skill_points_changed.emit(skill_points)
	grimoire_changed.emit("")
