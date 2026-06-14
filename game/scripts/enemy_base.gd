extends CharacterBody2D
class_name EnemyBase

signal died(enemy)

@export var max_hp := 4
@export var contact_damage := 1
@export var gravity := 800.0

var hp := 0
var _flash := 0.0
var _dead := false
var hit_stun := 0.0

@onready var visual: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")
	var hurt := get_node_or_null("Hurtbox")
	if hurt:
		hurt.add_to_group("enemy_hurtbox")
	var contact := get_node_or_null("ContactHitbox")
	if contact:
		contact.add_to_group("enemy_contact")
	_on_ready()

func _on_ready() -> void:
	pass

func take_damage(amount: int, knockback: Vector2) -> void:
	if _dead:
		return
	hp -= amount
	_flash = 0.12
	velocity = knockback
	hit_stun = 0.18
	if hp <= 0:
		_die()

func _process(delta: float) -> void:
	if _dead or visual == null:
		return
	if _flash > 0.0:
		_flash -= delta
		visual.modulate = Color(3, 3, 3)
	else:
		visual.modulate = Color(1, 1, 1)

func _die() -> void:
	_dead = true
	died.emit(self)
	queue_free()
