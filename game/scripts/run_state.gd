extends Node

signal materials_changed(id: String, count: int)
signal items_changed()
signal consumable_changed(id: String)

const MATERIALS_CONFIG := "res://data/materials.json"
const WEAPONS_CONFIG := "res://data/weapons.json"
const LEGACY_RESOURCE_MATERIAL := "cuivre"

var materials: Dictionary = {}
var items: Array[String] = []
var consumables: Dictionary = {}

var _material_defs: Dictionary = {}
var _weapon_defs: Dictionary = {}

func reset() -> void:
	materials.clear()
	items.clear()
	consumables.clear()
	_emit_all_materials()
	items_changed.emit()
	consumable_changed.emit("")

func add_material(id: String, qty: int) -> void:
	if qty <= 0:
		return
	var current := get_material(id)
	materials[id] = current + qty
	materials_changed.emit(id, int(materials[id]))

func get_material(id: String) -> int:
	return int(materials.get(id, 0))

func spend_materials(costs: Dictionary) -> bool:
	for raw_id in costs.keys():
		var id := String(raw_id)
		var qty := int(costs[raw_id])
		if get_material(id) < qty:
			return false
	for raw_id in costs.keys():
		var id := String(raw_id)
		var qty := int(costs[raw_id])
		materials[id] = get_material(id) - qty
		materials_changed.emit(id, int(materials[id]))
	return true

func get_material_ids() -> Array[String]:
	_ensure_material_defs()
	var ids: Array[String] = []
	for raw_id in _material_defs.keys():
		ids.append(String(raw_id))
	ids.sort()
	return ids

func get_material_config(id: String) -> Dictionary:
	_ensure_material_defs()
	var cfg: Variant = _material_defs.get(id, {})
	return cfg if cfg is Dictionary else {}

func get_material_name(id: String) -> String:
	var cfg := get_material_config(id)
	return String(cfg.get("name", id.capitalize()))

func get_material_tier(id: String) -> int:
	var cfg := get_material_config(id)
	return int(cfg.get("tier", 1))

func get_pickaxe_tier() -> int:
	_ensure_weapon_defs()
	var best_tier := 1
	for item_id in items:
		var cfg: Variant = _weapon_defs.get(item_id, {})
		if cfg is Dictionary:
			best_tier = max(best_tier, int(cfg.get("pickaxe_tier", 1)))
	return best_tier

func grant_dev_materials(qty: int) -> void:
	for id in get_material_ids():
		materials[id] = qty
		materials_changed.emit(id, qty)

func clear_dev_materials() -> void:
	for id in get_material_ids():
		materials[id] = 0
		materials_changed.emit(id, 0)

func add_item(id: String) -> void:
	items.append(id)
	items_changed.emit()

func has_item(id: String) -> bool:
	return id in items

func add_consumable(id: String) -> void:
	consumables[id] = get_consumable_count(id) + 1
	consumable_changed.emit(id)

func get_consumable_count(id: String) -> int:
	return int(consumables.get(id, 0))

func use_consumable() -> String:
	for id in consumables.keys():
		var count := int(consumables[id])
		if count > 0:
			count -= 1
			if count <= 0:
				consumables.erase(id)
			else:
				consumables[id] = count
			consumable_changed.emit(String(id) if count > 0 else "")
			return String(id)
	return ""

func serialize() -> Dictionary:
	return {
		"materials": materials.duplicate(),
		"items": items.duplicate(),
		"consumables": consumables.duplicate(),
	}

func deserialize(data: Dictionary) -> void:
	materials.clear()
	var has_materials := data.has("materials")
	var raw_materials: Variant = data.get("materials", {})
	if has_materials and raw_materials is Dictionary:
		for raw_id in raw_materials.keys():
			materials[String(raw_id)] = int(raw_materials[raw_id])
	elif "resources" in data:
		materials[LEGACY_RESOURCE_MATERIAL] = int(data.get("resources", 0))
	items = Array(data.get("items", []), TYPE_STRING, "", null)
	consumables = data.get("consumables", {}).duplicate()
	_emit_all_materials()
	items_changed.emit()
	consumable_changed.emit("")

func _ensure_material_defs() -> void:
	if not _material_defs.is_empty():
		return
	var file := FileAccess.open(MATERIALS_CONFIG, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_material_defs = parsed

func _ensure_weapon_defs() -> void:
	if not _weapon_defs.is_empty():
		return
	var file := FileAccess.open(WEAPONS_CONFIG, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_weapon_defs = parsed

func _emit_all_materials() -> void:
	for id in get_material_ids():
		materials_changed.emit(id, get_material(id))
