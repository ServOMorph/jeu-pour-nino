extends RefCounted
class_name RecipeCatalog

const RECIPE_FILE := "res://data/recipes.json"

static func load_recipes() -> Array[Dictionary]:
	var file := FileAccess.open(RECIPE_FILE, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Array:
		return []
	var recipes: Array[Dictionary] = []
	for entry in parsed:
		if entry is Dictionary:
			recipes.append(entry)
	return recipes

static func find_by_id(recipes: Array[Dictionary], recipe_id: String) -> Dictionary:
	for recipe in recipes:
		if String(recipe.get("id", "")) == recipe_id:
			return recipe
	return {}

static func bootstrap_starters(recipes: Array[Dictionary]) -> void:
	for recipe in recipes:
		if bool(recipe.get("starter", false)):
			MetaState.ensure_recipe(String(recipe.get("id", "")), true)
