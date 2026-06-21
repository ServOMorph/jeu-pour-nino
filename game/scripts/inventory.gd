extends Node

signal resources_changed(current: int)
signal items_changed()
signal consumable_changed(id: String)

var resources := 0
var items: Array[String] = []
var consumable := ""

func reset() -> void:
	resources = 0
	items.clear()
	consumable = ""
	resources_changed.emit(resources)
	items_changed.emit()
	consumable_changed.emit(consumable)

func add(amount: int) -> void:
	resources += amount
	resources_changed.emit(resources)

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
	consumable = id
	consumable_changed.emit(consumable)

func use_consumable() -> String:
	var id := consumable
	consumable = ""
	consumable_changed.emit(consumable)
	return id
