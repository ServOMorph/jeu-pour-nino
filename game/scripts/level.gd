extends Node2D

const PLAYER := preload("res://scenes/player/player.tscn")
const ENEMY_GROUND := preload("res://scenes/enemies/enemy_ground.tscn")
const ENEMY_FLYER := preload("res://scenes/enemies/enemy_flyer.tscn")
const BOSS := preload("res://scenes/enemies/boss.tscn")

const RECIPE_CATALOG := preload("res://scripts/recipe_catalog.gd")
const BIOME_CLEARED_SCRIPT := preload("res://scripts/biome_cleared.gd")
const ORE_NODE := preload("res://scripts/ore_node.gd")
const WORKBENCH_SCRIPT := preload("res://scripts/workbench.gd")
const CRAFT_MENU_SCRIPT := preload("res://scripts/craft_menu.gd")
const EQUIPMENT_MENU_SCRIPT := preload("res://scripts/equipment_menu.gd")

const ORE_SURFACE_OFFSET := Vector2(0, 32)
const HUB_PORTAL_SCRIPT := preload("res://scripts/hub_portal.gd")

var player: CharacterBody2D
var boss: Node = null
var _biome_id := "biome1"
var _boss_started := false
var _ended := false
var _door: StaticBody2D = null
var _level_cfg: Dictionary = {}
var _living_enemies := 0
var _background_layers: Array = []
var _camera: Camera2D = null

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
	_biome_id = GameFlow.next_biome_id
	_level_cfg = GameFlow.load_biome_config(_biome_id)
	if _level_cfg.is_empty():
		return
	RunState.mark_biome_visited(_biome_id)
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
	_spawn_exit_portal()
	_setup_hud()
	_setup_pause_menu()
	_setup_equipment_menu()
	_setup_grimoire_menu()
	if cfg["boss_active"] and boss:
		_start_boss_fight()

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
	if _ended or _boss_started or boss == null:
		return
	var dims: Dictionary = _level_cfg["dimensions"]
	if player and player.global_position.x > float(dims["arena_x"]):
		_start_boss_fight()

func _process(_delta: float) -> void:
	if _ended:
		return
	_update_background_layers()
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
	for layer_cfg in bg_cfg.get("layers", []):
		_add_background_layer(layer_cfg)

func _add_background_layer(layer_cfg: Dictionary) -> void:
	var texture_path := String(layer_cfg.get("texture", ""))
	if texture_path.is_empty():
		return
	var image := Image.load_from_file(ProjectSettings.globalize_path(texture_path))
	if image == null or image.is_empty():
		push_warning("Background texture introuvable: %s" % texture_path)
		return
	var texture := ImageTexture.create_from_image(image)
	var node := Node2D.new()
	node.z_index = int(layer_cfg.get("z_index", -8))
	add_child(node)
	var dims: Dictionary = _level_cfg["dimensions"]
	var level_width := float(dims["width"])
	var scale := _cfg_vec2(layer_cfg.get("scale", [1.0, 1.0]), Vector2.ONE)
	var offset := _cfg_vec2(layer_cfg.get("offset", [0.0, 0.0]), Vector2.ZERO)
	var scroll_scale := _cfg_vec2(layer_cfg.get("scroll_scale", [1.0, 1.0]), Vector2.ONE)
	var opacity := float(layer_cfg.get("opacity", 1.0))
	var overlap := float(layer_cfg.get("overlap", 0.0))
	var repeat := bool(layer_cfg.get("repeat", true))
	var tile_width := texture.get_width() * scale.x
	if tile_width <= 0.0:
		return
	var step: float = maxf(64.0, tile_width - overlap)
	var x := -tile_width if repeat else 0.0
	var limit := level_width + tile_width if repeat else 1.0
	while x < limit:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.position = Vector2(x, 0.0)
		sprite.scale = scale
		sprite.modulate = Color(1.0, 1.0, 1.0, opacity)
		node.add_child(sprite)
		if not repeat:
			break
		x += step
	_background_layers.append({
		"node": node,
		"offset": offset,
		"scroll_scale": scroll_scale,
	})

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
	_camera = player.get_node("Camera2D")
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = int(dims["width"])
	_camera.limit_bottom = int(dims["height"])
	_update_background_layers()

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
	if RunState.is_boss_defeated(_biome_id):
		return
	boss = BOSS.instantiate()
	add_child(boss)
	boss.global_position = _vec2(_level_cfg["boss"]["pos"])
	boss.died.connect(_on_boss_died)

func _spawn_exit_portal() -> void:
	var exit_cfg: Dictionary = _level_cfg.get("exit_portal", {})
	if not exit_cfg.has("pos"):
		return
	var col: Array = exit_cfg.get("color", [0.4, 0.8, 0.7])
	var pos: Array = exit_cfg["pos"]
	var portal := HUB_PORTAL_SCRIPT.new()
	portal.label_text = String(exit_cfg.get("label", "RETOUR HUB"))
	portal.color = _color(col)
	add_child(portal)
	portal.global_position = _vec2(pos)
	portal.interact_requested.connect(_return_to_hub)

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

func _cfg_vec2(value: Variant, default_value: Vector2) -> Vector2:
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	if value is float or value is int:
		var f := float(value)
		return Vector2(f, f)
	return default_value

func _update_background_layers() -> void:
	if _background_layers.is_empty() or _camera == null:
		return
	var viewport_size := get_viewport_rect().size
	var left: float = maxf(0.0, _camera.global_position.x - viewport_size.x * 0.5)
	var top: float = maxf(0.0, _camera.global_position.y - viewport_size.y * 0.5)
	for layer in _background_layers:
		var node: Node2D = layer["node"]
		var offset: Vector2 = layer["offset"]
		var scroll_scale: Vector2 = layer["scroll_scale"]
		node.position = Vector2(
			left * (1.0 - scroll_scale.x) + offset.x,
			top * (1.0 - scroll_scale.y) + offset.y
		)

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
	_ended = true
	GameFlow.end_run(true)
	GameFlow.start_run()
	GameFlow.return_to_hub()

func _return_to_title() -> void:
	_ended = true
	GameFlow.end_run(true)
	GameFlow.return_to_title()

func _return_to_hub() -> void:
	if _ended:
		return
	_ended = true
	GameFlow.return_to_hub()

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
	var gained := GameFlow.end_run(true)
	_show_end_screen("VOUS ETES TOMBE", Color(0.8, 0.2, 0.2), false, gained)

func _on_boss_died() -> void:
	if _ended:
		return
	_ended = true
	_hud.hide_boss_bar()
	RunState.mark_boss_defeated(_biome_id)
	RECIPE_CATALOG.discover_by_trigger(RECIPE_CATALOG.load_recipes(), "Victoire Gardien du Voile")
	SaveManager.save_meta()
	_show_biome_cleared()

func _show_biome_cleared() -> void:
	await get_tree().create_timer(0.8).timeout
	var banner := BIOME_CLEARED_SCRIPT.new()
	add_child(banner)
	banner.setup(String(_level_cfg.get("name", _biome_id)))
	banner.finished.connect(GameFlow.return_to_hub)

func _show_end_screen(message: String, color: Color, victory: bool, pc_gained: int) -> void:
	await get_tree().create_timer(0.8).timeout
	var screen := END_SCREEN.new()
	add_child(screen)
	screen.setup(message, color, victory, pc_gained)
	get_tree().paused = true
