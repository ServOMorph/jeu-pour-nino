extends Control

enum State { MAIN, DEV }

const COLOR_SELECTED  := Color(1.0, 1.0, 1.0)
const COLOR_IDLE      := Color(0.45, 0.45, 0.45)
const COLOR_TOGGLE_ON := Color(0.4, 1.0, 0.4)
const GRIMOIRE_MENU_SCRIPT := preload("res://scripts/grimoire_menu.gd")
const RECIPE_CATALOG := preload("res://scripts/recipe_catalog.gd")

var _state    := State.MAIN
var _selected := 0
var _started  := false
var _a_was    := true

var _main_root:   Control
var _dev_root:    Control
var _main_labels: Array[Label] = []
var _dev_labels:  Array[Label] = []
var _grimoire_menu: CanvasLayer

const MAIN_ENTRIES := ["JOUER", "MODE DEV"]
const DEV_ENTRIES  := ["[ ] 100 MAT", "[ ] VIE INF", "[ ] PC INFINI", "[ ] SANS MOBS", "[ ] ONE SHOT", "GRIMOIRE", "HUB", "BIOME DIRECT", "ATELIER", "TEST BOSS", "TOUT DECOUVRIR (DEV)", "RETOUR"]

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.10)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var title := Label.new()
	title.text = "CoreDive Challenge"
	title.add_theme_font_size_override("font_size", 96)
	title.add_theme_color_override("font_color", Color(0.7, 0.4, 0.9))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 112)
	title.size = Vector2(1920, 128)
	add_child(title)

	var sub := Label.new()
	sub.text = "Sauras-tu atteindre le Noyau ?"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 44)
	sub.position = Vector2(0, 264)
	sub.size = Vector2(1920, 80)
	add_child(sub)

	_build_main_menu()
	_build_dev_menu()
	_setup_grimoire_menu()

	_show_main()

func _build_main_menu() -> void:
	_main_root = Control.new()
	add_child(_main_root)
	for i in MAIN_ENTRIES.size():
		var lbl := Label.new()
		lbl.text = MAIN_ENTRIES[i]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 56)
		lbl.position = Vector2(0, 504 + i * 112)
		lbl.size = Vector2(1920, 88)
		_main_root.add_child(lbl)
		_main_labels.append(lbl)

func _build_dev_menu() -> void:
	_dev_root = Control.new()
	add_child(_dev_root)

	var dev_title := Label.new()
	dev_title.text = "— MODE DEV —"
	dev_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dev_title.add_theme_font_size_override("font_size", 44)
	dev_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	dev_title.position = Vector2(0, 372)
	dev_title.size = Vector2(1920, 64)
	_dev_root.add_child(dev_title)

	const DEV_ROW_H := 50.0
	for i in DEV_ENTRIES.size():
		var lbl := Label.new()
		lbl.text = DEV_ENTRIES[i]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 30)
		lbl.position = Vector2(0, 440 + i * DEV_ROW_H)
		lbl.size = Vector2(1920, 46)
		_dev_root.add_child(lbl)
		_dev_labels.append(lbl)

	_dev_root.visible = false

func _show_main() -> void:
	_state = State.MAIN
	_selected = 0
	_main_root.visible = true
	_dev_root.visible = false
	_refresh()

func _show_dev() -> void:
	_state = State.DEV
	_selected = 0
	_main_root.visible = false
	_dev_root.visible = true
	_refresh()

func _refresh() -> void:
	match _state:
		State.MAIN:
			for i in _main_labels.size():
				_main_labels[i].add_theme_color_override("font_color",
					COLOR_SELECTED if i == _selected else COLOR_IDLE)
		State.DEV:
			for i in _dev_labels.size():
				var is_toggle := i <= 4
				if is_toggle:
					var enabled := _toggle_enabled(i)
					var label := _toggle_label(i)
					_dev_labels[i].text = ("[X] %s" if enabled else "[ ] %s") % label
					var col: Color
					if i == _selected:
						col = COLOR_TOGGLE_ON if enabled else COLOR_SELECTED
					else:
						col = COLOR_TOGGLE_ON if enabled else COLOR_IDLE
					_dev_labels[i].add_theme_color_override("font_color", col)
				else:
					_dev_labels[i].add_theme_color_override("font_color",
						COLOR_SELECTED if i == _selected else COLOR_IDLE)

func _toggle_enabled(i: int) -> bool:
	match i:
		0: return Dev.dev_resources > 0
		1: return Dev.infinite_hp
		2: return Dev.pc_infinite
		3: return Dev.no_enemies
		4: return Dev.one_shot
	return false

func _toggle_label(i: int) -> String:
	match i:
		0: return "100 MAT"
		1: return "VIE INF"
		2: return "PC INFINI"
		3: return "SANS MOBS"
		4: return "ONE SHOT"
	return ""

func _process(_delta: float) -> void:
	if _grimoire_menu and _grimoire_menu.visible:
		return
	var a := false
	for pad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_A):
			a = true
	var a_just := a and not _a_was
	_a_was = a

	if _started:
		return

	if Input.is_action_just_pressed("ui_down"):
		_selected = (_selected + 1) % _current_size()
		_refresh()
	elif Input.is_action_just_pressed("ui_up"):
		_selected = (_selected - 1 + _current_size()) % _current_size()
		_refresh()

	if Input.is_action_just_pressed("ui_cancel"):
		if _state == State.DEV:
			_show_main()
		return

	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") or a_just:
		_confirm()

func _current_size() -> int:
	return MAIN_ENTRIES.size() if _state == State.MAIN else DEV_ENTRIES.size()

func _confirm() -> void:
	match _state:
		State.MAIN:
			match _selected:
				0: _start_game("", false)
				1: _show_dev()
		State.DEV:
			match _selected:
				0: Dev.dev_resources = 0 if Dev.dev_resources > 0 else 100; _refresh()
				1: Dev.infinite_hp = not Dev.infinite_hp; _refresh()
				2: _toggle_dev_pc()
				3: Dev.no_enemies = not Dev.no_enemies; _refresh()
				4: Dev.one_shot = not Dev.one_shot; _refresh()
				5: _grimoire_menu.open_menu()
				6: _start_game("", false)
				7: _start_game("", true)
				8: _start_game("atelier", true)
				9: _start_game("boss", true)
				10: _discover_all_recipes()
				11: _show_main()

func _toggle_dev_pc() -> void:
	Dev.pc_infinite = not Dev.pc_infinite
	MetaState.grant_dev_skill_points(9999 if Dev.pc_infinite else 0)
	_refresh()

func _discover_all_recipes() -> void:
	for recipe in RECIPE_CATALOG.load_recipes():
		MetaState.discover_recipe(String(recipe.get("id", "")))
	_grimoire_menu.open_menu()

func _setup_grimoire_menu() -> void:
	_grimoire_menu = GRIMOIRE_MENU_SCRIPT.new()
	add_child(_grimoire_menu)

func _start_game(spawn: String, direct_biome: bool) -> void:
	if _started:
		return
	_started = true
	Dev.spawn = spawn
	GameFlow.start_run()
	if direct_biome:
		GameFlow.enter_biome(GameFlow.next_biome_id)
	else:
		GameFlow.return_to_hub()
