extends Node

signal resources_changed(current: int)
signal items_changed()

var resources := 0
var items: Array[String] = []

func reset() -> void:
	resources = 0
	items.clear()
	resources_changed.emit(resources)
	items_changed.emit()

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
