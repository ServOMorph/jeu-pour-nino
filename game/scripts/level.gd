extends Node2D

const PLAYER := preload("res://scenes/player/player.tscn")
const ENEMY_GROUND := preload("res://scenes/enemies/enemy_ground.tscn")
const ENEMY_FLYER := preload("res://scenes/enemies/enemy_flyer.tscn")
const BOSS := preload("res://scenes/enemies/boss.tscn")

const LEVEL_WIDTH := 1600.0
const LEVEL_HEIGHT := 270.0
const FLOOR_TOP := 240.0
const ARENA_X := 1150.0

var player: CharacterBody2D
var boss: Node = null
var _boss_started := false
var _ended := false
var _door: StaticBody2D = null

const END_SCREEN := preload("res://scripts/end_screen.gd")

# Elements UI (construits par code)
var hud: CanvasLayer
var hp_fill: ColorRect
var boss_bar_root: Control
var boss_fill: ColorRect

func _ready() -> void:
	randomize()
	_build_background()
	_build_geometry()
	_spawn_player()
	_spawn_enemies()
	_spawn_boss()
	_build_hud()

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
	# Plateformes du parcours
	_add_platform(Rect2(250, 200, 90, 12), c)
	_add_platform(Rect2(410, 165, 80, 12), c)
	_add_platform(Rect2(560, 130, 80, 12), c)
	_add_platform(Rect2(720, 175, 90, 12), c)
	_add_platform(Rect2(560, 240 - 60, 16, 60), c) # petit obstacle/marche
	_add_platform(Rect2(900, 190, 100, 12), c)
	_add_platform(Rect2(1040, 150, 80, 12), c)

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
	_add_ground_enemy(Vector2(320, FLOOR_TOP - 8))
	_add_ground_enemy(Vector2(680, FLOOR_TOP - 8))
	_add_ground_enemy(Vector2(980, FLOOR_TOP - 8))
	_add_flyer(Vector2(460, 150))
	_add_flyer(Vector2(820, 140))

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
	boss.global_position = Vector2(1460, FLOOR_TOP - 18)
	boss.died.connect(_on_boss_died)
	boss.health_changed.connect(_on_boss_health_changed)

func _start_boss_fight() -> void:
	_boss_started = true
	# Porte qui se ferme a l'entree de l'arene
	_door = _add_platform(Rect2(ARENA_X - 8, FLOOR_TOP - 140, 16, 140), Color(0.4, 0.15, 0.35))
	if boss and is_instance_valid(boss):
		boss.activate()
	boss_bar_root.visible = true

# ---------------------------------------------------------------------- HUD

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)

	# Barre de vie joueur
	var hp_bg := ColorRect.new()
	hp_bg.color = Color(0, 0, 0, 0.6)
	hp_bg.position = Vector2(8, 8)
	hp_bg.size = Vector2(84, 12)
	hud.add_child(hp_bg)
	hp_fill = ColorRect.new()
	hp_fill.color = Color(0.9, 0.25, 0.3)
	hp_fill.position = Vector2(10, 10)
	hp_fill.size = Vector2(80, 8)
	hud.add_child(hp_fill)
	var hp_label := Label.new()
	hp_label.text = "VIE"
	hp_label.position = Vector2(96, 6)
	hp_label.add_theme_font_size_override("font_size", 10)
	hud.add_child(hp_label)

	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.hp, player.MAX_HP)

	# Barre de vie boss (cachee au depart)
	boss_bar_root = Control.new()
	boss_bar_root.position = Vector2(90, 244)
	boss_bar_root.visible = false
	hud.add_child(boss_bar_root)
	var b_bg := ColorRect.new()
	b_bg.color = Color(0, 0, 0, 0.6)
	b_bg.size = Vector2(304, 14)
	boss_bar_root.add_child(b_bg)
	boss_fill = ColorRect.new()
	boss_fill.color = Color(0.6, 0.2, 0.85)
	boss_fill.position = Vector2(2, 2)
	boss_fill.size = Vector2(300, 10)
	boss_bar_root.add_child(boss_fill)
	var b_label := Label.new()
	b_label.text = "GARDIEN DU NOYAU"
	b_label.position = Vector2(0, -14)
	b_label.add_theme_font_size_override("font_size", 9)
	boss_bar_root.add_child(b_label)

func _on_player_health_changed(current: int, maximum: int) -> void:
	var ratio: float = float(current) / float(maximum)
	hp_fill.size.x = 80.0 * ratio

func _on_boss_health_changed(current: int, maximum: int) -> void:
	var ratio: float = float(current) / float(maximum)
	boss_fill.size.x = 300.0 * ratio

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
	boss_bar_root.visible = false
	_show_end_screen("NOYAU ATTEINT - VICTOIRE", Color(0.4, 0.85, 0.5), true)

func _show_end_screen(message: String, color: Color, victory: bool) -> void:
	await get_tree().create_timer(0.8).timeout
	var screen := END_SCREEN.new()
	add_child(screen)
	screen.setup(message, color, victory)
	get_tree().paused = true
