extends GutTest

const PROGRESSION := preload("res://scripts/progression.gd")

var menu: CanvasLayer

func before_each() -> void:
	RunState.reset()
	MetaState.reset_for_new_game()
	menu = load("res://scripts/craft_menu.gd").new()
	add_child_autofree(menu)

func _visible_ids() -> Array[String]:
	var ids: Array[String] = []
	for recipe in menu._visible_recipes:
		ids.append(String(recipe["id"]))
	return ids

func _find_index(id: String) -> int:
	for i in menu._visible_recipes.size():
		if String(menu._visible_recipes[i]["id"]) == id:
			return i
	return -1

func test_starters_are_mastered_on_bootstrap() -> void:
	assert_true(MetaState.is_mastered("epee_bois"))
	assert_true(MetaState.is_mastered("torche"))
	assert_false(MetaState.is_discovered("epee_cuivre"))

func test_visible_recipes_only_mastered() -> void:
	menu.open(1)
	var ids := _visible_ids()
	assert_true("epee_bois" in ids)
	assert_false("epee_cuivre" in ids)

func test_workbench_tier_filters_recipes() -> void:
	MetaState.discover_recipe("epee_fer")
	MetaState.master_recipe("epee_fer", 0)
	menu.open(1)
	assert_false("epee_fer" in _visible_ids())
	menu.open(2)
	assert_true("epee_fer" in _visible_ids())

func test_craft_debits_materials_and_grants_item() -> void:
	RunState.add_material("bois", 5)
	menu.open(1)
	var idx := _find_index("epee_bois")
	menu._try_craft(idx)
	assert_eq(RunState.get_material("bois"), 3)
	assert_true(RunState.has_item("epee_bois"))

func test_craft_fails_without_enough_materials() -> void:
	menu.open(1)
	var idx := _find_index("epee_bois")
	menu._try_craft(idx)
	assert_false(RunState.has_item("epee_bois"))
	assert_eq(RunState.get_material("bois"), 0)

func test_craft_multi_material_recipe_requires_all_materials() -> void:
	MetaState.discover_recipe("epee_cuivre")
	MetaState.master_recipe("epee_cuivre", 0)
	RunState.add_material("cuivre", 3)
	menu.open(1)
	var idx := _find_index("epee_cuivre")
	menu._try_craft(idx)
	assert_false(RunState.has_item("epee_cuivre"))
	RunState.add_material("bois", 1)
	menu._try_craft(idx)
	assert_true(RunState.has_item("epee_cuivre"))

func test_master_recipe_costs_skill_points() -> void:
	MetaState.discover_recipe("epee_cuivre")
	MetaState.add_skill_points(5)
	var result: bool = MetaState.master_recipe("epee_cuivre", 2)
	assert_true(result)
	assert_true(MetaState.is_mastered("epee_cuivre"))
	assert_eq(MetaState.skill_points, 3)

func test_master_recipe_fails_without_enough_skill_points() -> void:
	MetaState.discover_recipe("epee_cuivre")
	var result: bool = MetaState.master_recipe("epee_cuivre", 2)
	assert_false(result)
	assert_false(MetaState.is_mastered("epee_cuivre"))

func test_compute_skill_points_basic_run() -> void:
	var bareme := PROGRESSION.load_bareme()
	var counters := {"biomes_visited": 1, "bosses_defeated": 1}
	assert_eq(PROGRESSION.compute_skill_points(counters, bareme), 3)

func test_compute_skill_points_victory_bonus() -> void:
	var bareme := PROGRESSION.load_bareme()
	var counters := {"biomes_visited": 1, "bosses_defeated": 1, "victory": true}
	assert_eq(PROGRESSION.compute_skill_points(counters, bareme), 6)

func test_compute_skill_points_run_failed_applies_multiplier() -> void:
	var bareme := PROGRESSION.load_bareme()
	var counters := {"biomes_visited": 1, "bosses_defeated": 1, "run_failed": true}
	assert_eq(PROGRESSION.compute_skill_points(counters, bareme), 2)

func test_compute_skill_points_uses_real_bareme_values() -> void:
	var bareme := PROGRESSION.load_bareme()
	assert_eq(int(bareme["boss_defeated"]), 2)
	assert_eq(int(bareme["victory_bonus"]), 3)
	assert_almost_eq(float(bareme["failure_multiplier"]), 0.5, 0.001)
