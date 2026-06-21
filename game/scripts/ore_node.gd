extends StaticBody2D

const ORE_SIZE := Vector2(14, 14)
const ORE_HP := 3
const ORE_DROP := 1

var _hp := ORE_HP
var _visual: Polygon2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = ORE_SIZE
	shape.shape = rs
	add_child(shape)

	_visual = Polygon2D.new()
	_visual.color = Color(0.25, 0.55, 0.85)
	var h := ORE_SIZE * 0.5
	_visual.polygon = PackedVector2Array([
		Vector2(-h.x, -h.y), Vector2(h.x, -h.y),
		Vector2(h.x, h.y), Vector2(-h.x, h.y)
	])
	add_child(_visual)

	var hurtbox := Area2D.new()
	hurtbox.add_to_group("mineable_hurtbox")
	hurtbox.collision_layer = 8
	hurtbox.collision_mask = 8
	var hb_shape := CollisionShape2D.new()
	var hb_rs := RectangleShape2D.new()
	hb_rs.size = ORE_SIZE
	hb_shape.shape = hb_rs
	hurtbox.add_child(hb_shape)
	add_child(hurtbox)

func take_damage(amount: int, _knockback: Vector2) -> void:
	_hp -= amount
	_flash()
	if _hp <= 0:
		Inventory.add(ORE_DROP)
		queue_free()

func _flash() -> void:
	var t := create_tween()
	t.tween_property(_visual, "color", Color(1, 1, 1), 0.06)
	t.tween_property(_visual, "color", Color(0.25, 0.55, 0.85), 0.10)
