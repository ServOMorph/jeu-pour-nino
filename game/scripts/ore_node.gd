extends StaticBody2D

const ORE_SIZE := Vector2(14, 14)
const ORE_HP := 3
const ORE_DROP := 1
const ORE_TEXTURE := preload("res://assets/sprites/objects/ore_copper.png")

var _hp := ORE_HP
var _visual: Sprite2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = ORE_SIZE
	shape.shape = rs
	add_child(shape)

	_visual = Sprite2D.new()
	_visual.texture = ORE_TEXTURE
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
	_burst_particles(4, false)
	AudioManager.play("mine")
	if _hp <= 0:
		Inventory.add(ORE_DROP)
		_burst_particles(10, true)
		AudioManager.play("mine_break")
		queue_free()

func _flash() -> void:
	var t := create_tween()
	t.tween_property(_visual, "modulate", Color(1, 1, 1), 0.06)
	t.tween_property(_visual, "modulate", Color(1, 1, 1, 1), 0.10)

func _burst_particles(count: int, big: bool) -> void:
	var p := CPUParticles2D.new()
	get_parent().add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = count
	var lt := 0.5 if big else 0.3
	p.lifetime = lt
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, 300)
	p.initial_velocity_min = 40.0 if big else 20.0
	p.initial_velocity_max = 100.0 if big else 50.0
	p.color = Color(0.25, 0.55, 0.85)
	get_tree().create_timer(lt + 0.1).timeout.connect(p.queue_free)
