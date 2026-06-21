extends StaticBody2D

signal interact_requested

const SIZE := Vector2(20, 18)
const ZONE_SIZE := Vector2(60, 50)

var _in_range := false
var _prompt: Label

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = SIZE
	shape.shape = rs
	add_child(shape)

	var body_vis := Polygon2D.new()
	body_vis.color = Color(0.45, 0.30, 0.18)
	var h := SIZE * 0.5
	body_vis.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x, -h.y),
		Vector2(h.x, h.y), Vector2(-h.x, h.y)
	])
	add_child(body_vis)

	var top_vis := Polygon2D.new()
	top_vis.color = Color(0.58, 0.42, 0.24)
	top_vis.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x, -h.y),
		Vector2(h.x, -h.y + 5), Vector2(-h.x, -h.y + 5)
	])
	add_child(top_vis)

	var zone := Area2D.new()
	zone.collision_layer = 0
	zone.collision_mask = 2
	var zshape := CollisionShape2D.new()
	var zrs := RectangleShape2D.new()
	zrs.size = ZONE_SIZE
	zshape.shape = zrs
	zone.add_child(zshape)
	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)
	add_child(zone)

	_prompt = Label.new()
	_prompt.text = "Y : crafter"
	_prompt.add_theme_font_size_override("font_size", 8)
	_prompt.position = Vector2(-18, -22)
	_prompt.visible = false
	add_child(_prompt)

func _process(_delta: float) -> void:
	if _in_range and Input.is_action_just_pressed("interact"):
		interact_requested.emit()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = true
		_prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = false
		_prompt.visible = false
