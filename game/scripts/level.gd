extends Node2D

const PLAYER := preload("res://scenes/player/player.tscn")
const ENEMY_GROUND := preload("res://scenes/enemies/enemy_ground.tscn")
const ENEMY_FLYER := preload("res://scenes/enemies/enemy_flyer.tscn")
const BOSS := preload("res://scenes/enemies/boss.tscn")

const ORE_NODE := preload("res://scripts/ore_node.gd")
const WORKBENCH_SCRIPT := preload("res://scripts/workbench.gd")
const CRAFT_MENU_SCRIPT := preload("res://scripts/craft_menu.gd")

const LEVEL_WIDTH := 3200.0
const LEVEL_HEIGHT := 270.0
const FLOOR_TOP := 240.0
const ARENA_X := 2600.0

var player: CharacterBody2D
var boss: Node = null
var _boss_started := false
var _ended := false
var _door: StaticBody2D = null

const END_SCREEN := preload("res://scripts/end_screen.gd")
const HUD_SCRIPT := preload("res://scripts/hud.gd")

var _hud: CanvasLayer
var _craft_menu: CanvasLayer

func _ready() -> void:
	randomize()
	Inventory.reset()
	if Dev.dev_resources > 0:
		Inventory.add(Dev.dev_resources)
	_build_background()
	_build_geometry()
	_spawn_player()
	var cfg := _resolve_spawn()
	if cfg["enemies"]:
		_spawn_enemies()
	_spawn_boss()
	_spawn_ores()
	_spawn_workbench()
	_setup_hud()
	player.global_position = cfg["pos"]
	if cfg["boss_active"]:
		_start_boss_fight()

# Registre des points de spawn dev. Ajouter une entree ici (+ un bouton dans
# title.gd) suffit pour exposer un nouveau point de test.
func _spawn_points() -> Dictionary:
	return {
		"start":   {"pos": Vector2(60, FLOOR_TOP - 16),       "enemies": true,  "boss_active": false},
		"atelier": {"pos": Vector2(1040, FLOOR_TOP - 16),    "enemies": false, "boss_active": false},
		"boss":    {"pos": Vector2(ARENA_X + 60, FLOOR_TOP - 16), "enemies": false, "boss_active": true},
	}

func _resolve_spawn() -> Dictionary:
	var points := _spawn_points()
	var key: String = Dev.spawn if Dev.spawn in points else "start"
	return points[key]

func _physics_process(_delta: float) -> void:
	if _ended or _boss_started:
		return
	if player and player.global_position.x > ARENA_X:
		_start_boss_fight()


# ---------------------------------------------------------------- Construction

func _build_background() -> void:
	var bg := Polygon2D.new()
	bg.color = Color(0.12, 0.10, 0.08)
	bg.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(LEVEL_WIDTH, 0),
		Vector2(LEVEL_WIDTH, LEVEL_HEIGHT), Vector2(0, LEVEL_HEIGHT)
	])
	bg.z_index = -10
	add_child(bg)
	# Marqueur visuel de l'arene du boss (fond plus sombre)
	var arena := Polygon2D.new()
	arena.color = Color(0.18, 0.08, 0.16)
	arena.polygon = PackedVector2Array([
		Vector2(ARENA_X, 0), Vector2(LEVEL_WIDTH, 0),
		Vector2(LEVEL_WIDTH, LEVEL_HEIGHT), Vector2(ARENA_X, LEVEL_HEIGHT)
	])
	arena.z_index = -9
	add_child(arena)

func _build_geometry() -> void:
	var c := Color(0.22, 0.20, 0.18)
	# Sol continu
	_add_platform(Rect2(0, FLOOR_TOP, LEVEL_WIDTH, 30), c)
	# Murs lateraux
	_add_platform(Rect2(-8, 0, 8, LEVEL_HEIGHT), c)
	_add_platform(Rect2(LEVEL_WIDTH, 0, 8, LEVEL_HEIGHT), c)
	# Zone 1 (0-1100)
	_add_platform(Rect2(250, 200, 90, 12), c)
	_add_platform(Rect2(410, 165, 80, 12), c)
	_add_platform(Rect2(560, 130, 80, 12), c)
	_add_platform(Rect2(720, 175, 90, 12), c)
	_add_platform(Rect2(560, 180, 16, 60), c)
	_add_platform(Rect2(900, 195, 100, 12), c)
	_add_platform(Rect2(1040, 155, 80, 12), c)
	# Zone 2 (1100-2600)
	_add_platform(Rect2(1200, 200, 90, 12), c)
	_add_platform(Rect2(1380, 160, 80, 12), c)
	_add_platform(Rect2(1540, 125, 80, 12), c)
	_add_platform(Rect2(1700, 170, 90, 12), c)
	_add_platform(Rect2(1700, 180, 16, 60), c)
	_add_platform(Rect2(1900, 200, 100, 12), c)
	_add_platform(Rect2(2060, 155, 80, 12), c)
	_add_platform(Rect2(2220, 195, 90, 12), c)
	_add_platform(Rect2(2400, 165, 80, 12), c)
	_add_platform(Rect2(2520, 200, 120, 12), c)

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

func _spawn_player() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	player.add_to_group("player")
	player.global_position = Vector2(60, FLOOR_TOP - 16)
	player.died.connect(_on_player_died)
	var cam: Camera2D = player.get_node("Camera2D")
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(LEVEL_WIDTH)
	cam.limit_bottom = int(LEVEL_HEIGHT)

func _spawn_enemies() -> void:
	# Zone 1
	_add_ground_enemy(Vector2(320, FLOOR_TOP - 8))
	_add_ground_enemy(Vector2(680, FLOOR_TOP - 8))
	_add_flyer(Vector2(470, 145))
	_add_flyer(Vector2(810, 140))
	# Zone 2
	_add_ground_enemy(Vector2(1150, FLOOR_TOP - 8))
	_add_ground_enemy(Vector2(1500, FLOOR_TOP - 8))
	_add_ground_enemy(Vector2(1860, FLOOR_TOP - 8))
	_add_ground_enemy(Vector2(2200, FLOOR_TOP - 8))
	_add_ground_enemy(Vector2(2450, FLOOR_TOP - 8))
	_add_flyer(Vector2(1350, 145))
	_add_flyer(Vector2(1760, 130))
	_add_flyer(Vector2(2110, 145))

func _add_ground_enemy(pos: Vector2) -> void:
	var e := ENEMY_GROUND.instantiate()
	add_child(e)
	e.global_position = pos

func _add_flyer(pos: Vector2) -> void:
	var e := ENEMY_FLYER.instantiate()
	add_child(e)
	e.global_position = pos

func _spawn_boss() -> void:
	boss = BOSS.instantiate()
	add_child(boss)
	boss.global_position = Vector2(2860, FLOOR_TOP - 18)
	boss.died.connect(_on_boss_died)

func _spawn_ores() -> void:
	var positions := [
		# Zone 1 — avant l'etabli
		Vector2(180, FLOOR_TOP - 15),
		Vector2(300, 200 - 15),
		Vector2(460, 165 - 15),
		Vector2(600, FLOOR_TOP - 15),
		Vector2(760, 175 - 15),
		Vector2(1050, FLOOR_TOP - 15),
		# Zone 2 — apres l'etabli
		Vector2(1260, 200 - 15),
		Vector2(1590, FLOOR_TOP - 15),
		Vector2(1770, 170 - 15),
		Vector2(2000, 200 - 15),
		Vector2(2250, FLOOR_TOP - 15),
		Vector2(2460, 165 - 15),
	]
	for pos in positions:
		var ore := ORE_NODE.new()
		add_child(ore)
		ore.global_position = pos

func _spawn_workbench() -> void:
	_craft_menu = CRAFT_MENU_SCRIPT.new()
	add_child(_craft_menu)
	var wb := WORKBENCH_SCRIPT.new()
	add_child(wb)
	wb.global_position = Vector2(1100, FLOOR_TOP - 9)
	wb.interact_requested.connect(_craft_menu.open)

func _start_boss_fight() -> void:
	_boss_started = true
	# Porte qui se ferme a l'entree de l'arene
	_door = _add_platform(Rect2(ARENA_X - 8, FLOOR_TOP - 140, 16, 140), Color(0.4, 0.15, 0.35))
	if boss and is_instance_valid(boss):
		boss.activate()
	_hud.show_boss_bar()

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
