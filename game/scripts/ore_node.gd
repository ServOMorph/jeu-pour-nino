extends StaticBody2D

const DEFAULT_SIZE := Vector2(14, 14)
const DEFAULT_HP := 3
const DEFAULT_DROP := 1
const DEFAULT_TEXTURE_PATH := "res://assets/sprites/objects/ore_copper.png"

var material_id := "cuivre"

var _hp := DEFAULT_HP
var _drop := DEFAULT_DROP
var _size := DEFAULT_SIZE
var _required_tier := 1
var _texture_path := DEFAULT_TEXTURE_PATH
var _visual: Sprite2D

func _ready() -> void:
	_load_material_config()
	collision_layer = 1
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = _size
	shape.shape = rs
	add_child(shape)

	_visual = Sprite2D.new()
	var image := Image.load_from_file(ProjectSettings.globalize_path(_texture_path))
	if image != null and not image.is_empty():
		_visual.texture = ImageTexture.create_from_image(image)
	add_child(_visual)

	var hurtbox := Area2D.new()
	hurtbox.add_to_group("mineable_hurtbox")
	hurtbox.collision_layer = 8
	hurtbox.collision_mask = 8
	var hb_shape := CollisionShape2D.new()
	var hb_rs := RectangleShape2D.new()
	hb_rs.size = _size
	hb_shape.shape = hb_rs
	hurtbox.add_child(hb_shape)
	add_child(hurtbox)

func take_damage(amount: int, _knockback: Vector2) -> void:
	if RunState.get_pickaxe_tier() < _required_tier:
		AudioManager.play("cant_craft")
		return
	_hp -= amount
	_flash()
	_burst_particles(4, false)
	AudioManager.play("mine")
	if _hp <= 0:
		RunState.add_material(material_id, _drop)
		_burst_particles(10, true)
		AudioManager.play("mine_break")
		queue_free()

func _load_material_config() -> void:
	var cfg := RunState.get_material_config(material_id)
	_required_tier = int(cfg.get("tier", 1))
	var ore_cfg: Variant = cfg.get("ore", {})
	if ore_cfg is not Dictionary:
		return
	_hp = int(ore_cfg.get("hp", DEFAULT_HP))
	_drop = int(ore_cfg.get("drop", DEFAULT_DROP))
	var size_data: Variant = ore_cfg.get("size", [DEFAULT_SIZE.x, DEFAULT_SIZE.y])
	if size_data is Array and size_data.size() >= 2:
		_size = Vector2(float(size_data[0]), float(size_data[1]))
	_texture_path = String(ore_cfg.get("sprite", DEFAULT_TEXTURE_PATH))

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
