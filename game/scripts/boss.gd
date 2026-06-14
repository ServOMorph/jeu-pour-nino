extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

const MAX_HP := 40
const GRAVITY := 800.0
const CHARGE_SPEED := 150.0
const WALK_SPEED := 30.0

const PROJECTILE := preload("res://scenes/enemies/boss_projectile.tscn")

enum State { SLEEP, IDLE, CHARGE, VOLLEY, SLAM_RISE, SLAM_FALL, PAUSE }

@export var contact_damage := 2

var hp := MAX_HP
var state: int = State.SLEEP
var _state_time := 0.0
var _flash := 0.0
var _player: Node2D = null
var _facing := -1.0
var _slam_origin_y := 0.0

@onready var visual: Polygon2D = $Visual
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	hp = MAX_HP
	hurtbox.add_to_group("enemy_hurtbox")
	_player = get_tree().get_first_node_in_group("player")
	set_physics_process(false)

func activate() -> void:
	_player = get_tree().get_first_node_in_group("player")
	health_changed.emit(hp, MAX_HP)
	_set_state(State.IDLE)
	set_physics_process(true)
	AudioManager.play("boss")

func take_damage(amount: int, knockback: Vector2) -> void:
	if state == State.SLEEP:
		return
	hp = max(0, hp - amount)
	_flash = 0.1
	health_changed.emit(hp, MAX_HP)
	if hp <= 0:
		_die()

func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash -= delta
		visual.modulate = Color(2.5, 2.5, 2.5)
	else:
		visual.modulate = Color(1, 1, 1)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and state != State.SLAM_RISE:
		velocity.y = min(velocity.y + GRAVITY * delta, 400.0)
	if is_on_floor() and state not in [State.SLAM_RISE, State.SLAM_FALL]:
		velocity.y = 0.0

	if _player and is_instance_valid(_player):
		_facing = sign(_player.global_position.x - global_position.x)
		if _facing == 0:
			_facing = -1.0
		visual.scale.x = _facing

	_state_time -= delta

	match state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
			if _state_time <= 0.0:
				_choose_attack()
		State.CHARGE:
			velocity.x = _facing * CHARGE_SPEED
			if is_on_wall() or _state_time <= 0.0:
				_set_state(State.PAUSE, 0.6)
		State.VOLLEY:
			if _state_time <= 0.0:
				_set_state(State.PAUSE, 0.7)
		State.SLAM_RISE:
			velocity.x = move_toward(velocity.x, 0.0, 200.0 * delta)
			if _state_time <= 0.0:
				velocity.y = 700.0
				_set_state(State.SLAM_FALL)
		State.SLAM_FALL:
			velocity.x = 0.0
			if is_on_floor():
				_slam_impact()
				_set_state(State.PAUSE, 0.8)
		State.PAUSE:
			velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
			if _state_time <= 0.0:
				_set_state(State.IDLE, 0.5)

	move_and_slide()

func _set_state(s: int, duration: float = 0.6) -> void:
	state = s
	_state_time = duration

func _choose_attack() -> void:
	var dist := 9999.0
	if _player and is_instance_valid(_player):
		dist = abs(_player.global_position.x - global_position.x)
	var roll := randi() % 3
	if roll == 0 and dist > 60.0:
		_set_state(State.CHARGE, 1.2)
	elif roll == 1:
		_fire_volley()
		_set_state(State.VOLLEY, 0.5)
	else:
		velocity.y = -260.0
		_set_state(State.SLAM_RISE, 0.5)

func _fire_volley() -> void:
	if not (_player and is_instance_valid(_player)):
		return
	var base_dir := (_player.global_position - global_position).normalized()
	for i in range(3):
		var p := PROJECTILE.instantiate()
		get_parent().add_child(p)
		p.global_position = global_position
		var ang := deg_to_rad((i - 1) * 18.0)
		p.direction = base_dir.rotated(ang)

func _slam_impact() -> void:
	if _player and is_instance_valid(_player):
		var cam = _player.get_node_or_null("Camera2D")
		if cam and cam.has_method("add_trauma"):
			cam.add_trauma(6.0)
	# Onde de choc : degats si le joueur est au sol et proche
	if _player and is_instance_valid(_player):
		var dx: float = abs(_player.global_position.x - global_position.x)
		if dx < 70.0 and _player.has_method("take_damage"):
			if _player.is_on_floor():
				_player.take_damage(contact_damage, global_position.x)

func _die() -> void:
	state = State.SLEEP
	set_physics_process(false)
	visual.color = Color(0.3, 0.2, 0.35)
	AudioManager.play("victory")
	died.emit()
	queue_free()
