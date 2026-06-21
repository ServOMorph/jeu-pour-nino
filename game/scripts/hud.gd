extends CanvasLayer

var _hp_fill: ColorRect
var _boss_bar_root: Control
var _boss_fill: ColorRect

func setup(player: Node, boss: Node) -> void:
	_build_player_bar(player)
	_build_boss_bar(boss)

func _build_player_bar(player: Node) -> void:
	var hp_bg := ColorRect.new()
	hp_bg.color = Color(0, 0, 0, 0.6)
	hp_bg.position = Vector2(8, 8)
	hp_bg.size = Vector2(84, 12)
	add_child(hp_bg)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.9, 0.25, 0.3)
	_hp_fill.position = Vector2(10, 10)
	_hp_fill.size = Vector2(80, 8)
	add_child(_hp_fill)
	var hp_label := Label.new()
	hp_label.text = "VIE"
	hp_label.position = Vector2(96, 6)
	hp_label.add_theme_font_size_override("font_size", 10)
	add_child(hp_label)
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.hp, player.max_hp)

func _build_boss_bar(boss: Node) -> void:
	_boss_bar_root = Control.new()
	_boss_bar_root.position = Vector2(90, 244)
	_boss_bar_root.visible = false
	add_child(_boss_bar_root)
	var b_bg := ColorRect.new()
	b_bg.color = Color(0, 0, 0, 0.6)
	b_bg.size = Vector2(304, 14)
	_boss_bar_root.add_child(b_bg)
	_boss_fill = ColorRect.new()
	_boss_fill.color = Color(0.6, 0.2, 0.85)
	_boss_fill.position = Vector2(2, 2)
	_boss_fill.size = Vector2(300, 10)
	_boss_bar_root.add_child(_boss_fill)
	var b_label := Label.new()
	b_label.text = "GARDIEN DU NOYAU"
	b_label.position = Vector2(0, -14)
	b_label.add_theme_font_size_override("font_size", 9)
	_boss_bar_root.add_child(b_label)
	boss.health_changed.connect(_on_boss_health_changed)

func show_boss_bar() -> void:
	_boss_bar_root.visible = true

func hide_boss_bar() -> void:
	_boss_bar_root.visible = false

func _on_player_health_changed(current: int, maximum: int) -> void:
	_hp_fill.size.x = 80.0 * float(current) / float(maximum)

func _on_boss_health_changed(current: int, maximum: int) -> void:
	_boss_fill.size.x = 300.0 * float(current) / float(maximum)
