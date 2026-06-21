extends CharacterBody2D
class_name EnemyBase

signal died(enemy)

const ENEMY_CONFIG_FILE := "res://data/enemies.json"

@export var max_hp := 5
@export var contact_damage := 1
@export var gravity := 800.0

var hp := 0
var _flash := 0.0
var _dead := false
var hit_stun := 0.0

@onready var visual: Polygon2D = get_node_or_null("Visual")

func _ready() -> void:
	_load_config()
	hp = max_hp
	add_to_group("enemies")
	var hurt := get_node_or_null("Hurtbox")
	if hurt:
		hurt.add_to_group("enemy_hurtbox")
	var contact := get_node_or_null("ContactHitbox")
	if contact:
		contact.add_to_group("enemy_contact")
	_on_ready()

func _load_config() -> void:
	var f := FileAccess.open(ENEMY_CONFIG_FILE, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not parsed is Dictionary:
		return
	var cfg: Variant = parsed.get(name, null)
	if not cfg is Dictionary:
		return
	if "max_hp" in cfg:
		max_hp = int(cfg["max_hp"])
	if "contact_damage" in cfg:
		contact_damage = int(cfg["contact_damage"])

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
