extends GutTest

var rs: Node

func before_each() -> void:
	rs = load("res://scripts/run_state.gd").new()
	add_child_autofree(rs)

func test_initial_state_is_empty() -> void:
	assert_true(rs.materials.is_empty())
	assert_true(rs.items.is_empty())
	assert_true(rs.consumables.is_empty())

func test_add_and_get_material() -> void:
	rs.add_material("cuivre", 10)
	assert_eq(rs.get_material("cuivre"), 10)
	assert_eq(rs.get_material("bois"), 0)

func test_spend_materials_succeeds_when_enough() -> void:
	rs.add_material("cuivre", 20)
	rs.add_material("bois", 5)
	var result: bool = rs.spend_materials({"cuivre": 15, "bois": 2})
	assert_true(result)
	assert_eq(rs.get_material("cuivre"), 5)
	assert_eq(rs.get_material("bois"), 3)

func test_spend_materials_is_atomic() -> void:
	rs.add_material("cuivre", 5)
	rs.add_material("bois", 1)
	var result: bool = rs.spend_materials({"cuivre": 4, "bois": 2})
	assert_false(result)
	assert_eq(rs.get_material("cuivre"), 5)
	assert_eq(rs.get_material("bois"), 1)

func test_add_item_and_has_item() -> void:
	rs.add_item("epee_bois")
	assert_true(rs.has_item("epee_bois"))
	assert_false(rs.has_item("epee_fer"))

func test_consumable_use() -> void:
	rs.add_consumable("potion_petite")
	rs.add_consumable("potion_petite")
	assert_eq(rs.get_consumable_count("potion_petite"), 2)
	var used: String = rs.use_consumable()
	assert_eq(used, "potion_petite")
	assert_eq(rs.get_consumable_count("potion_petite"), 1)

func test_reset_clears_everything() -> void:
	rs.add_material("cuivre", 50)
	rs.add_item("epee_bois")
	rs.add_consumable("potion")
	rs.reset()
	assert_eq(rs.get_material("cuivre"), 0)
	assert_true(rs.items.is_empty())
	assert_true(rs.consumables.is_empty())

func test_serialize_deserialize_roundtrip() -> void:
	rs.add_material("cuivre", 30)
	rs.add_material("bois", 4)
	rs.add_item("armure_bois")
	rs.equip_item("armor", "armure_bois")
	rs.add_consumable("potion_petite")
	rs.set_active_consumable("potion_petite")
	var data: Dictionary = rs.serialize()
	var rs2: Node = load("res://scripts/run_state.gd").new()
	add_child_autofree(rs2)
	rs2.deserialize(data)
	assert_eq(rs2.get_material("cuivre"), 30)
	assert_eq(rs2.get_material("bois"), 4)
	assert_true(rs2.has_item("armure_bois"))
	assert_eq(rs2.get_equipped_item("armor"), "armure_bois")
	assert_eq(rs2.get_consumable_count("potion_petite"), 1)
	assert_eq(rs2.active_consumable, "potion_petite")

func test_deserialize_legacy_resources_maps_to_cuivre() -> void:
	rs.deserialize({"resources": 12})
	assert_eq(rs.get_material("cuivre"), 12)

func test_pickaxe_tier_defaults_to_one() -> void:
	assert_eq(rs.get_pickaxe_tier(), 1)

func test_pickaxe_tier_follows_best_owned_weapon() -> void:
	rs.add_item("epee_bois")
	assert_eq(rs.get_pickaxe_tier(), 1)
	rs.add_item("epee_cuivre")
	assert_eq(rs.get_pickaxe_tier(), 2)
	rs.add_item("epee_fer")
	assert_eq(rs.get_pickaxe_tier(), 3)

func test_equip_item_requires_owned_item() -> void:
	assert_false(rs.equip_item("weapon", "epee_bois"))
	rs.add_item("epee_bois")
	assert_true(rs.equip_item("weapon", "epee_bois"))
	assert_eq(rs.get_equipped_item("weapon"), "epee_bois")

func test_increment_and_get_counter() -> void:
	rs.increment_counter("bosses_defeated")
	rs.increment_counter("bosses_defeated", 2)
	assert_eq(rs.get_counter("bosses_defeated"), 3)

func test_counter_flag_and_get_counters() -> void:
	rs.set_counter_flag("run_failed", true)
	var counters: Dictionary = rs.get_counters()
	assert_true(bool(counters["run_failed"]))

func test_reset_clears_counters() -> void:
	rs.increment_counter("biomes_visited")
	rs.reset()
	assert_eq(rs.get_counter("biomes_visited"), 0)
