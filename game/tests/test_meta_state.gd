extends GutTest

var ms: Node

func before_each() -> void:
	ms = load("res://scripts/meta_state.gd").new()
	add_child_autofree(ms)

func test_initial_state() -> void:
	assert_eq(ms.skill_points, 0)
	assert_true(ms.grimoire.is_empty())

func test_add_and_spend_skill_points() -> void:
	ms.add_skill_points(5)
	assert_eq(ms.skill_points, 5)
	var result := ms.spend_skill_points(3)
	assert_true(result)
	assert_eq(ms.skill_points, 2)

func test_spend_fails_when_insufficient() -> void:
	ms.add_skill_points(1)
	var result := ms.spend_skill_points(5)
	assert_false(result)
	assert_eq(ms.skill_points, 1)

func test_discover_recipe() -> void:
	ms.discover_recipe("potion_soin")
	assert_true(ms.is_discovered("potion_soin"))
	assert_false(ms.is_mastered("potion_soin"))

func test_master_recipe() -> void:
	ms.discover_recipe("potion_soin")
	var result := ms.master_recipe("potion_soin")
	assert_true(result)
	assert_true(ms.is_mastered("potion_soin"))

func test_master_undiscovered_recipe_fails() -> void:
	var result := ms.master_recipe("recette_inconnue")
	assert_false(result)

func test_discover_is_idempotent() -> void:
	ms.discover_recipe("torche")
	ms.discover_recipe("torche")
	assert_eq(ms.grimoire.size(), 1)

func test_serialize_deserialize_roundtrip() -> void:
	ms.add_skill_points(10)
	ms.discover_recipe("epee_bois")
	ms.master_recipe("epee_bois")
	var data := ms.serialize()
	var ms2: Node = load("res://scripts/meta_state.gd").new()
	add_child_autofree(ms2)
	ms2.deserialize(data)
	assert_eq(ms2.skill_points, 10)
	assert_true(ms2.is_mastered("epee_bois"))

func test_reset_for_new_game() -> void:
	ms.add_skill_points(10)
	ms.discover_recipe("epee_bois")
	ms.reset_for_new_game()
	assert_eq(ms.skill_points, 0)
	assert_true(ms.grimoire.is_empty())
