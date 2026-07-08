extends CanvasLayer

var _hp_fill: ColorRect
var _boss_bar_root: Control
var _boss_fill: ColorRect
var _materials_label: Label
var _consumable_label: Label

func setup(player: Node, boss: Node) -> void:
	_build_player_bar(player)
	_build_boss_bar(boss)
	_build_resource_counter()

func _build_player_bar(player: Node) -> void:
	var hp_bg := ColorRect.new()
	hp_bg.color = Color(0, 0, 0, 0.6)
	hp_bg.position = Vector2(32, 32)
	hp_bg.size = Vector2(336, 48)
	add_child(hp_bg)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.9, 0.25, 0.3)
	_hp_fill.position = Vector2(40, 40)
	_hp_fill.size = Vector2(320, 32)
	add_child(_hp_fill)
	var hp_label := Label.new()
	hp_label.text = "VIE"
	hp_label.position = Vector2(384, 24)
	hp_label.add_theme_font_size_override("font_size", 40)
	add_child(hp_label)
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.hp, player.max_hp)

func _build_boss_bar(boss: Node) -> void:
	_boss_bar_root = Control.new()
	_boss_bar_root.position = Vector2(360, 976)
	_boss_bar_root.visible = false
	add_child(_boss_bar_root)
	var b_bg := ColorRect.new()
	b_bg.color = Color(0, 0, 0, 0.6)
	b_bg.size = Vector2(1216, 56)
	_boss_bar_root.add_child(b_bg)
	_boss_fill = ColorRect.new()
	_boss_fill.color = Color(0.6, 0.2, 0.85)
	_boss_fill.position = Vector2(8, 8)
	_boss_fill.size = Vector2(1200, 40)
	_boss_bar_root.add_child(_boss_fill)
	var b_label := Label.new()
	b_label.text = "GARDIEN DU NOYAU"
	b_label.position = Vector2(0, -56)
	b_label.add_theme_font_size_override("font_size", 36)
	_boss_bar_root.add_child(b_label)
	boss.health_changed.connect(_on_boss_health_changed)

func _build_resource_counter() -> void:
	_materials_label = Label.new()
	_materials_label.position = Vector2(32, 96)
	_materials_label.size = Vector2(880, 168)
	_materials_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_materials_label.add_theme_font_size_override("font_size", 40)
	_materials_label.modulate = Color(0.6, 0.85, 1.0)
	add_child(_materials_label)
	RunState.materials_changed.connect(_on_materials_changed)
	_refresh_materials()

	_consumable_label = Label.new()
	_consumable_label.position = Vector2(32, 272)
	_consumable_label.add_theme_font_size_override("font_size", 40)
	add_child(_consumable_label)
	RunState.consumable_changed.connect(_on_consumable_changed)
	_on_consumable_changed("")

func _on_materials_changed(_id: String, _count: int) -> void:
	_refresh_materials()

func _refresh_materials() -> void:
	var parts: Array[String] = []
	for id in RunState.get_material_ids():
		var count := RunState.get_material(id)
		if count <= 0:
			continue
		parts.append("%s %d" % [_material_short_label(id), count])
	if parts.is_empty():
		_materials_label.text = "MAT -"
	else:
		_materials_label.text = "MAT " + " | ".join(parts)

func _material_short_label(id: String) -> String:
	var name := RunState.get_material_name(id).to_upper()
	return name.left(3)

func _on_consumable_changed(id: String) -> void:
	var active_id := id if not id.is_empty() else RunState.active_consumable
	if active_id.is_empty():
		_consumable_label.text = "LB: -"
		_consumable_label.modulate = Color(0.4, 0.4, 0.4)
	else:
		var count := RunState.get_consumable_count(active_id)
		_consumable_label.text = "LB: %s x%d" % [active_id.to_upper(), count]
		_consumable_label.modulate = Color(0.5, 1.0, 0.5)

func show_boss_bar() -> void:
	_boss_bar_root.visible = true

func hide_boss_bar() -> void:
	_boss_bar_root.visible = false

func _on_player_health_changed(current: int, maximum: int) -> void:
	_hp_fill.size.x = 320.0 * float(current) / float(maximum)

func _on_boss_health_changed(current: int, maximum: int) -> void:
	_boss_fill.size.x = 1200.0 * float(current) / float(maximum)
