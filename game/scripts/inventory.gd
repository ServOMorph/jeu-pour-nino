extends Node

signal resources_changed(current: int)
signal coins_changed(current: int)
signal items_changed()
signal consumable_changed(id: String)

var resources := 0
var coins := 0
var items: Array[String] = []
var consumables: Dictionary = {}

func reset() -> void:
	resources = 0
	coins = 0
	items.clear()
	consumables.clear()
	resources_changed.emit(resources)
	coins_changed.emit(coins)
	items_changed.emit()
	consumable_changed.emit("")

func add(amount: int) -> void:
	resources += amount
	resources_changed.emit(resources)

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func spend(amount: int) -> bool:
	if resources < amount:
		return false
	resources -= amount
	resources_changed.emit(resources)
	return true

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
