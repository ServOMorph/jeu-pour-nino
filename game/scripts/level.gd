extends Node2D

const PLAYER := preload("res://scenes/player/player.tscn")
const ENEMY_GROUND := preload("res://scenes/enemies/enemy_ground.tscn")
const ENEMY_FLYER := preload("res://scenes/enemies/enemy_flyer.tscn")
const BOSS := preload("res://scenes/enemies/boss.tscn")

const RECIPE_CATALOG := preload("res://scripts/recipe_catalog.gd")
const PROGRESSION := preload("res://scripts/progression.gd")
const ORE_NODE := preload("res://scripts/ore_node.gd")
const WORKBENCH_SCRIPT := preload("res://scripts/workbench.gd")
const CRAFT_MENU_SCRIPT := preload("res://scripts/craft_menu.gd")
const EQUIPMENT_MENU_SCRIPT := preload("res://scripts/equipment_menu.gd")

const LEVEL_CONFIG := "res://data/level.json"
const ORE_SURFACE_OFFSET := Vector2(0, 32)

var player: CharacterBody2D
var boss: Node = null
var _boss_started := false
var _ended := false
var _door: StaticBody2D = null
var _level_cfg: Dictionary = {}
var _living_enemies := 0

const END_SCREEN := preload("res://scripts/end_screen.gd")
const HUD_SCRIPT := preload("res://scripts/hud.gd")
const PAUSE_MENU_SCRIPT := preload("res://scripts/pause_menu.gd")
const GRIMOIRE_MENU_SCRIPT := preload("res://scripts/grimoire_menu.gd")

var _hud: CanvasLayer
var _craft_menu: CanvasLayer
var _pause_menu: CanvasLayer
var _equipment_menu: CanvasLayer
var _grimoire_menu: CanvasLayer

func _ready() -> void:
	randomize()
	_load_level_config()
	RunState.reset()
	RunState.increment_counter("biomes_visited", 1)
	if Dev.dev_resources > 0:
		RunState.grant_dev_materials(Dev.dev_resources)
	_build_background()
	_build_geometry()
	var cfg := _resolve_spawn()
	_spawn_player(cfg["pos"])
	if cfg["enemies"] and not Dev.no_enemies:
		_spawn_enemies()
	_spawn_boss()
	_spawn_ores()
	_spawn_workbench()
	_setup_hud()
	_setup_pause_menu()
	_setup_equipment_menu()
	_setup_grimoire_menu()
	if cfg["boss_active"]:
		_start_boss_fight()

func _load_level_config() -> void:
	var f := FileAccess.open(LEVEL_CONFIG, FileAccess.READ)
	if f == null:
		push_error("Config niveau introuvable: %s" % LEVEL_CONFIG)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		_level_cfg = parsed
	else:
		push_error("Config niveau invalide: %s" % LEVEL_CONFIG)

func _resolve_spawn() -> Dictionary:
	var points: Dictionary = _level_cfg.get("spawns", {})
	var key: String = Dev.spawn if Dev.spawn in points else "start"
	var cfg: Dictionary = points[key]
	return {
		"pos": _vec2(cfg["pos"]),
		"enemies": cfg["enemies"],
		"boss_active": cfg["boss_active"],
	}

func _physics_process(_delta: float) -> void:
	if _ended or _boss_started:
		return
	var dims: Dictionary = _level_cfg["dimensions"]
	if player and player.global_position.x > float(dims["arena_x"]):
		_start_boss_fight()

func _process(_delta: float) -> void:
	if _ended:
		return
	if Input.is_action_just_pressed("pause_menu") and _pause_menu and not _pause_menu.is_open():
		_open_pause_menu()


# ---------------------------------------------------------------- Construction

func _build_background() -> void:
	var dims: Dictionary = _level_cfg["dimensions"]
	var bg_cfg: Dictionary = _level_cfg["background"]
	var level_width := float(dims["width"])
	var level_height := float(dims["height"])
	var arena_x := float(dims["arena_x"])
	var bg := Polygon2D.new()
	bg.color = _color(bg_cfg["color"])
	bg.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(level_width, 0),
		Vector2(level_width, level_height), Vector2(0, level_height)
	])
	bg.z_index = int(bg_cfg["z_index"])
	add_child(bg)
	var arena := Polygon2D.new()
	arena.color = _color(bg_cfg["arena_color"])
	arena.polygon = PackedVector2Array([
		Vector2(arena_x, 0), Vector2(level_width, 0),
		Vector2(level_width, level_height), Vector2(arena_x, level_height)
	])
	arena.z_index = int(bg_cfg["arena_z_index"])
	add_child(arena)

func _build_geometry() -> void:
	var cfg: Dictionary = _level_cfg["platforms"]
	var c := _color(cfg["color"])
	for rect_data in cfg["rects"]:
		_add_platform(_rect(rect_data), c)

func _add_platform(rect: Rect2, color: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	body.position = rect.position + rect.size * 0.5
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	shape.shape = rs
	body.add_child(shape)
	var vis := Polygon2D.new()
	vis.color = color
	var h := rect.size * 0.5
	vis.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x, -h.y),
		Vector2(h.x, h.y), Vector2(-h.x, h.y)
	])
	body.add_child(vis)
	return body

func _spawn_player(spawn_pos: Vector2) -> void:
	var dims: Dictionary = _level_cfg["dimensions"]
	player = PLAYER.instantiate()
	add_child(player)
	player.add_to_group("player")
	player.global_position = spawn_pos
	player.died.connect(_on_player_died)
	var cam: Camera2D = player.get_node("Camera2D")
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(dims["width"])
	cam.limit_bottom = int(dims["height"])

func _spawn_enemies() -> void:
	for cfg in _level_cfg["enemies"]:
		_spawn_enemy_from_config(cfg)

func _spawn_enemy_from_config(cfg: Dictionary) -> void:
	var pos := _vec2(cfg["pos"])
	var enemy: Node = null
	match String(cfg["type"]):
		"ground":
			enemy = _add_ground_enemy(pos)
		"flyer":
			enemy = _add_flyer(pos)
	if enemy:
		_living_enemies += 1
		enemy.died.connect(_on_enemy_died.bind(cfg))

func _add_ground_enemy(pos: Vector2) -> Node:
	var e := ENEMY_GROUND.instantiate()
	add_child(e)
	e.global_position = pos
	return e

func _add_flyer(pos: Vector2) -> Node:
	var e := ENEMY_FLYER.instantiate()
	add_child(e)
	e.global_position = pos
	return e

func _on_enemy_died(_enemy: Node, cfg: Dictionary) -> void:
	_living_enemies = max(0, _living_enemies - 1)
	var respawn: Dictionary = _level_cfg.get("respawn", {})
	if not bool(respawn.get("enabled", false)):
		return
	if _ended or _boss_started:
		return
	get_tree().create_timer(float(respawn["delay"])).timeout.connect(_try_respawn_enemy.bind(cfg))

func _try_respawn_enemy(cfg: Dictionary) -> void:
	var respawn: Dictionary = _level_cfg.get("respawn", {})
	if _ended or _boss_started:
		return
	if _living_enemies >= int(respawn["max_alive"]):
		get_tree().create_timer(float(respawn["retry_delay"])).timeout.connect(_try_respawn_enemy.bind(cfg))
		return
	if player and is_instance_valid(player):
		var pos := _vec2(cfg["pos"])
		if player.global_position.distance_to(pos) < float(respawn["min_player_distance"]):
			get_tree().create_timer(float(respawn["retry_delay"])).timeout.connect(_try_respawn_enemy.bind(cfg))
			return
	_spawn_enemy_from_config(cfg)

func _spawn_boss() -> void:
	boss = BOSS.instantiate()
	add_child(boss)
	boss.global_position = _vec2(_level_cfg["boss"]["pos"])
	boss.died.connect(_on_boss_died)

func _spawn_ores() -> void:
	for ore_cfg in _level_cfg["ores"]:
		var ore := ORE_NODE.new()
		ore.material_id = String(ore_cfg.get("material", "cuivre"))
		add_child(ore)
		ore.global_position = _vec2(ore_cfg["pos"]) + ORE_SURFACE_OFFSET

func _spawn_workbench() -> void:
	_craft_menu = CRAFT_MENU_SCRIPT.new()
	add_child(_craft_menu)
	var wb := WORKBENCH_SCRIPT.new()
	add_child(wb)
	wb.global_position = _vec2(_level_cfg["workbench"]["pos"])
	wb.interact_requested.connect(func() -> void: _craft_menu.open(wb.workbench_tier))

func _start_boss_fight() -> void:
	if _boss_started:
		return
	_boss_started = true
	var door: Dictionary = _level_cfg["boss_door"]
	if _door == null:
		_door = _add_platform(_rect(door["rect"]), _color(door["color"]))
	if boss and is_instance_valid(boss):
		boss.activate()
	_hud.show_boss_bar()

func _vec2(data: Array) -> Vector2:
	return Vector2(float(data[0]), float(data[1]))

func _rect(data: Array) -> Rect2:
	return Rect2(float(data[0]), float(data[1]), float(data[2]), float(data[3]))

func _color(data: Array) -> Color:
	return Color(float(data[0]), float(data[1]), float(data[2]))

# ---------------------------------------------------------------------- HUD

func _setup_hud() -> void:
	_hud = HUD_SCRIPT.new()
	add_child(_hud)
	_hud.setup(player, boss)

func _setup_pause_menu() -> void:
	_pause_menu = PAUSE_MENU_SCRIPT.new()
	add_child(_pause_menu)
	_pause_menu.equipment_requested.connect(_open_equipment_menu)
	_pause_menu.resume_requested.connect(_close_pause_menu)
	_pause_menu.restart_requested.connect(_restart_run)
	_pause_menu.title_requested.connect(_return_to_title)
	_pause_menu.dev_resources_requested.connect(_toggle_dev_resources)
	_pause_menu.dev_hp_requested.connect(_toggle_dev_hp)
	_pause_menu.dev_pc_requested.connect(_toggle_dev_pc)
	_pause_menu.dev_no_enemies_requested.connect(_toggle_dev_no_enemies)
	_pause_menu.dev_one_shot_requested.connect(_toggle_dev_one_shot)
	_pause_menu.dev_grimoire_requested.connect(_open_grimoire_menu)
	_pause_menu.teleport_requested.connect(_teleport_to_spawn)

func _open_pause_menu() -> void:
	if _craft_menu and _craft_menu.visible:
		return
	if _equipment_menu and _equipment_menu.visible:
		return
	get_tree().paused = true
	_pause_menu.open_menu()

func _setup_equipment_menu() -> void:
	_equipment_menu = EQUIPMENT_MENU_SCRIPT.new()
	add_child(_equipment_menu)
	_equipment_menu.closed.connect(_reopen_pause_menu)

func _open_equipment_menu() -> void:
	if _pause_menu:
		_pause_menu.hide_menu()
	_equipment_menu.open_menu()

func _setup_grimoire_menu() -> void:
	_grimoire_menu = GRIMOIRE_MENU_SCRIPT.new()
	add_child(_grimoire_menu)
	_grimoire_menu.closed.connect(_reopen_pause_menu)

func _open_grimoire_menu() -> void:
	if _pause_menu:
		_pause_menu.hide_menu()
	_grimoire_menu.open_menu()

func _reopen_pause_menu() -> void:
	if _ended:
		return
	_pause_menu.open_menu()

func _close_pause_menu() -> void:
	if _pause_menu:
		_pause_menu.hide_menu()
	get_tree().paused = false

func _restart_run() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _return_to_title() -> void:
	get_tree().paused = false
	get_tree().quit()

func _toggle_dev_resources() -> void:
	if Dev.dev_resources > 0:
		Dev.dev_resources = 0
		RunState.clear_dev_materials()
	else:
		Dev.dev_resources = 100
		RunState.grant_dev_materials(Dev.dev_resources)

func _toggle_dev_hp() -> void:
	Dev.infinite_hp = not Dev.infinite_hp

func _toggle_dev_pc() -> void:
	Dev.pc_infinite = not Dev.pc_infinite
	MetaState.grant_dev_skill_points(9999 if Dev.pc_infinite else 0)

func _toggle_dev_no_enemies() -> void:
	Dev.no_enemies = not Dev.no_enemies
	if Dev.no_enemies:
		_clear_all_enemies()

func _clear_all_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	_living_enemies = 0

func _toggle_dev_one_shot() -> void:
	Dev.one_shot = not Dev.one_shot
	if player and is_instance_valid(player):
		player._apply_equipment()

func _teleport_to_spawn(spawn_key: String) -> void:
	var points: Dictionary = _level_cfg.get("spawns", {})
	if not points.has(spawn_key) or player == null:
		return
	var cfg: Dictionary = points[spawn_key]
	player.global_position = _vec2(cfg["pos"])
	player.velocity = Vector2.ZERO
	if bool(cfg.get("boss_active", false)):
		_start_boss_fight()

# --------------------------------------------------------------- Fin de partie

func _on_player_died() -> void:
	if _ended:
		return
	_ended = true
	RunState.set_counter_flag("run_failed", true)
	var gained := _award_skill_points()
	SaveManager.save_meta()
	_show_end_screen("VOUS ETES TOMBE", Color(0.8, 0.2, 0.2), false, gained)

func _on_boss_died() -> void:
	if _ended:
		return
	_ended = true
	_hud.hide_boss_bar()
	RunState.increment_counter("bosses_defeated", 1)
	RECIPE_CATALOG.discover_by_trigger(RECIPE_CATALOG.load_recipes(), "Victoire Gardien du Voile")
	var gained := _award_skill_points()
	SaveManager.save_meta()
	_show_end_screen("NOYAU ATTEINT - VICTOIRE", Color(0.4, 0.85, 0.5), true, gained)

func _award_skill_points() -> int:
	var bareme := PROGRESSION.load_bareme()
	var gained := PROGRESSION.compute_skill_points(RunState.get_counters(), bareme)
	MetaState.add_skill_points(gained)
	return gained

func _show_end_screen(message: String, color: Color, victory: bool, pc_gained: int) -> void:
	await get_tree().create_timer(0.8).timeout
	var screen := END_SCREEN.new()
	add_child(screen)
	screen.setup(message, color, victory, pc_gained)
	get_tree().paused = true
