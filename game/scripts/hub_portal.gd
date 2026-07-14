extends Area2D

signal interact_requested

const SIZE := Vector2(120, 220)
const ZONE_SIZE := Vector2(260, 260)

var label_text := "ENTRER"
var color := Color(0.4, 0.8, 0.7)
var locked := false

var _in_range := false
var _prompt: Label

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = ZONE_SIZE
	shape.shape = rs
	add_child(shape)

	var vis := Polygon2D.new()
	vis.color = color if not locked else Color(0.3, 0.3, 0.3)
	var h := SIZE * 0.5
	vis.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x, -h.y),
		Vector2(h.x, h.y), Vector2(-h.x, h.y)
	])
	add_child(vis)

	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_font_size_override("font_size", 32)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-160, -190)
	name_label.size = Vector2(320, 48)
	name_label.modulate = Color(1, 1, 1) if not locked else Color(0.5, 0.5, 0.5)
	add_child(name_label)

	_prompt = Label.new()
	_prompt.text = "Y : entrer" if not locked else "EN CONSTRUCTION"
	_prompt.add_theme_font_size_override("font_size", 28)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.position = Vector2(-160, -140)
	_prompt.size = Vector2(320, 40)
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _in_range and not locked and Input.is_action_just_pressed("interact"):
		interact_requested.emit()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = true
		_prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = false
		_prompt.visible = false
