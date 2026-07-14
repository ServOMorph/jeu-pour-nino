extends Node2D

const PLAYER := preload("res://scenes/player/player.tscn")
const HUB_PORTAL_SCRIPT := preload("res://scripts/hub_portal.gd")
const WORKBENCH_SCRIPT := preload("res://scripts/workbench.gd")
const CRAFT_MENU_SCRIPT := preload("res://scripts/craft_menu.gd")
const EQUIPMENT_MENU_SCRIPT := preload("res://scripts/equipment_menu.gd")
const GRIMOIRE_MENU_SCRIPT := preload("res://scripts/grimoire_menu.gd")
const PAUSE_MENU_SCRIPT := preload("res://scripts/pause_menu.gd")
const HUD_SCRIPT := preload("res://scripts/hud.gd")

const HUB_CONFIG := "res://data/hub.json"

var player: CharacterBody2D
var _cfg: Dictionary = {}
var _hud: CanvasLayer
var _craft_menu: CanvasLayer
var _pause_menu: CanvasLayer
var _equipment_menu: CanvasLayer
var _grimoire_menu: CanvasLayer
var _grimoire_from_pause := false

func _ready() -> void:
	_load_config()
	if _cfg.is_empty():
		return
	if Dev.dev_resources > 0:
		RunState.grant_dev_materials(Dev.dev_resources)
	_build_background()
	_build_geometry()
	_spawn_player()
	_spawn_portals()
	_spawn_workbench()
	_spawn_grimoire()
	_setup_hud()
	_setup_pause_menu()
	_setup_equipment_menu()
	_setup_grimoire_menu()

func _load_config() -> void:
	var f := FileAccess.open(HUB_CONFIG, FileAccess.READ)
	if f == null:
		push_error("Config HUB introuvable: %s" % HUB_CONFIG)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		_cfg = parsed
	else:
		push_error("Config HUB invalide: %s" % HUB_CONFIG)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu") and _pause_menu and not _pause_menu.is_open():
		_open_pause_menu()

# ---------------------------------------------------------------- Construction

func _build_background() -> void:
	var dims: Dictionary = _cfg["dimensions"]
	var bg_cfg: Dictionary = _cfg["background"]
	var width := float(dims["width"])
	var height := float(dims["height"])
	var bg := Polygon2D.new()
	bg.color = _color(bg_cfg["color"])
	bg.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(width, 0),
		Vector2(width, height), Vector2(0, height)
	])
	bg.z_index = int(bg_cfg["z_index"])
	add_child(bg)

	var texture_path := String(bg_cfg.get("texture", ""))
	if texture_path.is_empty():
		return
	var image := Image.load_from_file(ProjectSettings.globalize_path(texture_path))
	if image == null or image.is_empty():
		return
	var decor := Sprite2D.new()
	decor.texture = ImageTexture.create_from_image(image)
	decor.centered = false
	decor.z_index = int(bg_cfg["z_index"]) + 1
	decor.scale = Vector2(width / float(image.get_width()), height / float(image.get_height()))
	add_child(decor)

func _build_geometry() -> void:
	var cfg: Dictionary = _cfg["platforms"]
	var c := _color(cfg["color"])
	for rect_data in cfg["rects"]:
		_add_platform(_rect(rect_data), c)

func _add_platform(rect: Rect2, color: Color) -> void:
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

func _spawn_player() -> void:
	var dims: Dictionary = _cfg["dimensions"]
	var spawn: Array = _cfg["spawn"]
	player = PLAYER.instantiate()
	add_child(player)
	player.add_to_group("player")
	player.global_position = _vec2(spawn)
	player.heal_full()
	var cam: Camera2D = player.get_node("Camera2D")
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(dims["width"])
	cam.limit_bottom = int(dims["height"])

func _spawn_portals() -> void:
	for portal_cfg in _cfg["portals"]:
		var cfg: Dictionary = portal_cfg
		var biome_id := String(cfg["biome"])
		var col: Array = cfg["color"]
		var pos: Array = cfg["pos"]
		var portal := HUB_PORTAL_SCRIPT.new()
		portal.label_text = String(cfg["label"])
		portal.color = _color(col)
		portal.locked = bool(cfg.get("locked", false))
		add_child(portal)
		portal.global_position = _vec2(pos)
		portal.interact_requested.connect(_on_portal_entered.bind(biome_id))

func _on_portal_entered(biome_id: String) -> void:
	GameFlow.enter_biome(biome_id)

func _spawn_workbench() -> void:
	var cfg: Dictionary = _cfg["workbench"]
	var pos: Array = cfg["pos"]
	_craft_menu = CRAFT_MENU_SCRIPT.new()
	add_child(_craft_menu)
	var wb := WORKBENCH_SCRIPT.new()
	wb.workbench_tier = int(cfg.get("tier", 1))
	add_child(wb)
	wb.global_position = _vec2(pos)
	wb.interact_requested.connect(func() -> void: _craft_menu.open(wb.workbench_tier))

func _spawn_grimoire() -> void:
	var cfg: Dictionary = _cfg["grimoire"]
	var col: Array = cfg["color"]
	var pos: Array = cfg["pos"]
	var stele := HUB_PORTAL_SCRIPT.new()
	stele.label_text = String(cfg["label"])
	stele.color = _color(col)
	add_child(stele)
	stele.global_position = _vec2(pos)
	stele.interact_requested.connect(_open_grimoire_menu)

# ------------------------------------------------------------------------- UI

func _setup_hud() -> void:
	_hud = HUD_SCRIPT.new()
	add_child(_hud)
	_hud.setup(player, null)

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

func _setup_equipment_menu() -> void:
	_equipment_menu = EQUIPMENT_MENU_SCRIPT.new()
	add_child(_equipment_menu)
	_equipment_menu.closed.connect(_reopen_pause_menu)

func _setup_grimoire_menu() -> void:
	_grimoire_menu = GRIMOIRE_MENU_SCRIPT.new()
	add_child(_grimoire_menu)
	_grimoire_menu.closed.connect(_on_grimoire_closed)

func _open_pause_menu() -> void:
	if _craft_menu and _craft_menu.visible:
		return
	if _equipment_menu and _equipment_menu.visible:
		return
	if _grimoire_menu and _grimoire_menu.visible:
		return
	get_tree().paused = true
	_pause_menu.open_menu()

func _open_equipment_menu() -> void:
	if _pause_menu:
		_pause_menu.hide_menu()
	_equipment_menu.open_menu()

func _open_grimoire_menu() -> void:
	_grimoire_from_pause = _pause_menu != null and _pause_menu.is_open()
	if _pause_menu:
		_pause_menu.hide_menu()
	get_tree().paused = true
	_grimoire_menu.open_menu()

func _on_grimoire_closed() -> void:
	if _grimoire_from_pause:
		_pause_menu.open_menu()
	else:
		get_tree().paused = false

func _reopen_pause_menu() -> void:
	_pause_menu.open_menu()

func _close_pause_menu() -> void:
	if _pause_menu:
		_pause_menu.hide_menu()
	get_tree().paused = false

func _restart_run() -> void:
	GameFlow.end_run(true)
	GameFlow.start_run()
	GameFlow.return_to_hub()

func _return_to_title() -> void:
	GameFlow.end_run(true)
	GameFlow.return_to_title()

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

func _toggle_dev_one_shot() -> void:
	Dev.one_shot = not Dev.one_shot
	if player and is_instance_valid(player):
		player._apply_equipment()

# --------------------------------------------------------------------- Helpers

func _vec2(data: Array) -> Vector2:
	return Vector2(float(data[0]), float(data[1]))

func _rect(data: Array) -> Rect2:
	return Rect2(float(data[0]), float(data[1]), float(data[2]), float(data[3]))

func _color(data: Array) -> Color:
	return Color(float(data[0]), float(data[1]), float(data[2]))
