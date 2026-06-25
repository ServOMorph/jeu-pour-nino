extends Node2D

const PLAYER := preload("res://scenes/player/player.tscn")
const ENEMY_GROUND := preload("res://scenes/enemies/enemy_ground.tscn")
const ENEMY_FLYER := preload("res://scenes/enemies/enemy_flyer.tscn")
const BOSS := preload("res://scenes/enemies/boss.tscn")

const ORE_NODE := preload("res://scripts/ore_node.gd")
const WORKBENCH_SCRIPT := preload("res://scripts/workbench.gd")
const CRAFT_MENU_SCRIPT := preload("res://scripts/craft_menu.gd")

const LEVEL_CONFIG := "res://data/level.json"

var player: CharacterBody2D
var boss: Node = null
var _boss_started := false
var _ended := false
var _door: StaticBody2D = null
var _level_cfg: Dictionary = {}
var _living_enemies := 0

const END_SCREEN := preload("res://scripts/end_screen.gd")
const HUD_SCRIPT := preload("res://scripts/hud.gd")

var _hud: CanvasLayer
var _craft_menu: CanvasLayer

func _ready() -> void:
	randomize()
	_load_level_config()
	Inventory.reset()
	if Dev.dev_resources > 0:
		Inventory.add(Dev.dev_resources)
	_build_background()
	_build_geometry()
	var cfg := _resolve_spawn()
	_spawn_player(cfg["pos"])
	if cfg["enemies"]:
		_spawn_enemies()
	_spawn_boss()
	_spawn_ores()
	_spawn_workbench()
	_setup_hud()
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
	for pos_data in _level_cfg["ores"]:
		var ore := ORE_NODE.new()
		add_child(ore)
		ore.global_position = _vec2(pos_data)

func _spawn_workbench() -> void:
	_craft_menu = CRAFT_MENU_SCRIPT.new()
	add_child(_craft_menu)
	var wb := WORKBENCH_SCRIPT.new()
	add_child(wb)
	wb.global_position = _vec2(_level_cfg["workbench"]["pos"])
	wb.interact_requested.connect(_craft_menu.open)

func _start_boss_fight() -> void:
	_boss_started = true
	var door: Dictionary = _level_cfg["boss_door"]
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

# --------------------------------------------------------------- Fin de partie

func _on_player_died() -> void:
	if _ended:
		return
	_ended = true
	_show_end_screen("VOUS ETES TOMBE", Color(0.8, 0.2, 0.2), false)

func _on_boss_died() -> void:
	if _ended:
		return
	_ended = true
	_hud.hide_boss_bar()
	_show_end_screen("NOYAU ATTEINT - VICTOIRE", Color(0.4, 0.85, 0.5), true)

func _show_end_screen(message: String, color: Color, victory: bool) -> void:
	await get_tree().create_timer(0.8).timeout
	var screen := END_SCREEN.new()
	add_child(screen)
	screen.setup(message, color, victory)
	get_tree().paused = true
