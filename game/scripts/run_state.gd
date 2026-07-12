extends Node

signal materials_changed(id: String, count: int)
signal items_changed()
signal consumable_changed(id: String)
signal equipment_changed(slot: String, id: String)

const MATERIALS_CONFIG := "res://data/materials.json"
const WEAPONS_CONFIG := "res://data/weapons.json"
const LEGACY_RESOURCE_MATERIAL := "cuivre"
const EQUIPMENT_SLOTS := ["weapon", "armor", "accessory", "tool"]

var materials: Dictionary = {}
var items: Array[String] = []
var consumables: Dictionary = {}
var equipped: Dictionary = {}
var active_consumable := ""
var run_counters: Dictionary = {}

var _material_defs: Dictionary = {}
var _weapon_defs: Dictionary = {}

func reset() -> void:
	materials.clear()
	items.clear()
	consumables.clear()
	equipped.clear()
	active_consumable = ""
	run_counters.clear()
	_emit_all_materials()
	items_changed.emit()
	consumable_changed.emit("")
	_emit_all_equipment()

func increment_counter(key: String, amount: int = 1) -> void:
	run_counters[key] = get_counter(key) + amount

func get_counter(key: String) -> int:
	return int(run_counters.get(key, 0))

func set_counter_flag(key: String, value: bool) -> void:
	run_counters[key] = value

func get_counters() -> Dictionary:
	return run_counters.duplicate()

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
	if has_item(id):
		return
	items.append(id)
	items_changed.emit()

func has_item(id: String) -> bool:
	return id in items

func add_consumable(id: String) -> void:
	consumables[id] = get_consumable_count(id) + 1
	if active_consumable.is_empty():
		active_consumable = id
	consumable_changed.emit(active_consumable)

func get_consumable_count(id: String) -> int:
	return int(consumables.get(id, 0))

func use_consumable() -> String:
	if active_consumable.is_empty():
		return ""
	var id := active_consumable
	var count := int(consumables.get(id, 0))
	if count <= 0:
		active_consumable = _find_next_consumable()
		consumable_changed.emit(active_consumable)
		return ""
	count -= 1
	if count <= 0:
		consumables.erase(id)
		active_consumable = _find_next_consumable()
	else:
		consumables[id] = count
	consumable_changed.emit(active_consumable)
	return id

func get_equipped_item(slot: String) -> String:
	return String(equipped.get(slot, ""))

func equip_item(slot: String, id: String) -> bool:
	if slot not in EQUIPMENT_SLOTS:
		return false
	if id.is_empty():
		equipped.erase(slot)
		equipment_changed.emit(slot, "")
		return true
	if not has_item(id):
		return false
	equipped[slot] = id
	equipment_changed.emit(slot, id)
	return true

func set_active_consumable(id: String) -> bool:
	if id.is_empty():
		active_consumable = ""
		consumable_changed.emit("")
		return true
	if get_consumable_count(id) <= 0:
		return false
	active_consumable = id
	consumable_changed.emit(active_consumable)
	return true

func serialize() -> Dictionary:
	return {
		"materials": materials.duplicate(),
		"items": items.duplicate(),
		"consumables": consumables.duplicate(),
		"equipped": equipped.duplicate(),
		"active_consumable": active_consumable,
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
	equipped = data.get("equipped", {}).duplicate()
	active_consumable = String(data.get("active_consumable", ""))
	if not active_consumable.is_empty() and get_consumable_count(active_consumable) <= 0:
		active_consumable = ""
	_emit_all_materials()
	items_changed.emit()
	consumable_changed.emit(active_consumable)
	_emit_all_equipment()

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

func _emit_all_equipment() -> void:
	for slot in EQUIPMENT_SLOTS:
		equipment_changed.emit(slot, get_equipped_item(slot))

func _find_next_consumable() -> String:
	for raw_id in consumables.keys():
		var id := String(raw_id)
		if int(consumables[raw_id]) > 0:
			return id
	return ""
