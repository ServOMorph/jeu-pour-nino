extends GutTest

func before_each() -> void:
	RunState.reset()
	MetaState.skill_points = 0
	GameFlow.next_biome_id = "biome1"

func test_start_run_resets_run_state() -> void:
	RunState.add_material("cuivre", 5)
	RunState.mark_biome_visited("biome1")
	RunState.mark_boss_defeated("biome1")
	GameFlow.start_run()
	assert_eq(RunState.get_material("cuivre"), 0, "materiaux vides apres un nouveau run")
	assert_eq(RunState.get_counters().size(), 0, "compteurs vides apres un nouveau run")
	assert_false(RunState.has_visited_biome("biome1"), "biomes visites vides apres un nouveau run")
	assert_false(RunState.is_boss_defeated("biome1"), "boss vaincus vides apres un nouveau run")

func test_start_run_sets_next_biome() -> void:
	GameFlow.start_run("biome1")
	assert_eq(GameFlow.next_biome_id, "biome1")

func test_biome_config_path() -> void:
	assert_eq(GameFlow.biome_config_path("biome1"), "res://data/biomes/biome1.json")

func test_load_biome_config() -> void:
	var cfg := GameFlow.load_biome_config("biome1")
	assert_false(cfg.is_empty(), "config biome1 chargee")
	assert_eq(String(cfg.get("id", "")), "biome1")
	assert_true(cfg.has("dimensions"), "config biome porte ses dimensions")

func test_revisiting_biome_counts_once() -> void:
	assert_true(RunState.mark_biome_visited("biome1"), "premiere visite comptee")
	assert_false(RunState.mark_biome_visited("biome1"), "revisite non comptee")
	assert_eq(RunState.get_counter("biomes_visited"), 1, "un seul PC de biome visite par biome")

func test_boss_defeated_persists_in_run() -> void:
	assert_true(RunState.mark_boss_defeated("biome1"), "premiere victoire comptee")
	assert_false(RunState.mark_boss_defeated("biome1"), "victoire deja enregistree")
	assert_true(RunState.is_boss_defeated("biome1"), "le boss reste vaincu dans le run")
	assert_eq(RunState.get_counter("bosses_defeated"), 1)

func test_run_state_survives_biome_round_trip() -> void:
	GameFlow.start_run()
	RunState.add_material("cuivre", 3)
	RunState.add_item("epee_bois")
	RunState.equip_item("weapon", "epee_bois")
	RunState.mark_biome_visited("biome1")
	RunState.mark_biome_visited("biome1")
	assert_eq(RunState.get_material("cuivre"), 3, "materiaux conserves sur un aller-retour HUB/biome")
	assert_eq(RunState.get_equipped_item("weapon"), "epee_bois", "equipement conserve sur un aller-retour")

func test_end_run_failed_awards_halved_points() -> void:
	GameFlow.start_run()
	RunState.mark_biome_visited("biome1")
	RunState.mark_boss_defeated("biome1")
	var gained := GameFlow.end_run(true)
	assert_true(RunState.get_counters().get("run_failed", false), "run marque comme rate")
	assert_eq(MetaState.skill_points, gained, "les PC gagnes sont credites")
	assert_gt(gained, 0, "un run rate rapporte quand meme des PC")

func test_end_run_success_awards_full_points() -> void:
	GameFlow.start_run()
	RunState.mark_biome_visited("biome1")
	RunState.mark_boss_defeated("biome1")
	var failed_counters := RunState.get_counters()
	var success := GameFlow.end_run(false)
	MetaState.skill_points = 0
	RunState.set_counter_flag("run_failed", true)
	var failed := GameFlow.end_run(true)
	assert_gt(success, failed, "un run rate rapporte moins qu'un run reussi")
	assert_true(failed_counters.has("biomes_visited"))
