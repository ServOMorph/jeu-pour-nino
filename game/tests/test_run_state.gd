extends GutTest

var rs: Node

func before_each() -> void:
	rs = load("res://scripts/run_state.gd").new()
	add_child_autofree(rs)

func test_initial_state_is_empty() -> void:
	assert_eq(rs.resources, 0)
	assert_eq(rs.coins, 0)
	assert_true(rs.items.is_empty())
	assert_true(rs.consumables.is_empty())

func test_add_resources() -> void:
	rs.add(10)
	assert_eq(rs.resources, 10)

func test_spend_succeeds_when_enough() -> void:
	rs.add(20)
	var result := rs.spend(15)
	assert_true(result)
	assert_eq(rs.resources, 5)

func test_spend_fails_when_insufficient() -> void:
	rs.add(5)
	var result := rs.spend(10)
	assert_false(result)
	assert_eq(rs.resources, 5)

func test_add_item_and_has_item() -> void:
	rs.add_item("epee_bois")
	assert_true(rs.has_item("epee_bois"))
	assert_false(rs.has_item("epee_fer"))

func test_consumable_use() -> void:
	rs.add_consumable("potion")
	rs.add_consumable("potion")
	assert_eq(rs.get_consumable_count("potion"), 2)
	var used := rs.use_consumable()
	assert_eq(used, "potion")
	assert_eq(rs.get_consumable_count("potion"), 1)

func test_reset_clears_everything() -> void:
	rs.add(50)
	rs.add_item("epee_bois")
	rs.add_consumable("potion")
	rs.reset()
	assert_eq(rs.resources, 0)
	assert_true(rs.items.is_empty())
	assert_true(rs.consumables.is_empty())

func test_serialize_deserialize_roundtrip() -> void:
	rs.add(30)
	rs.add_item("armure_bois")
	rs.add_consumable("potion")
	var data := rs.serialize()
	var rs2: Node = load("res://scripts/run_state.gd").new()
	add_child_autofree(rs2)
	rs2.deserialize(data)
	assert_eq(rs2.resources, 30)
	assert_true(rs2.has_item("armure_bois"))
	assert_eq(rs2.get_consumable_count("potion"), 1)
