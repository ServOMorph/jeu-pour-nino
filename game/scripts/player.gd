extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

const SPEED := 130.0
const ACCEL := 1600.0
const FRICTION := 1400.0
const AIR_ACCEL := 1000.0
const JUMP_VELOCITY := -320.0
const GRAVITY := 800.0
const FALL_GRAVITY := 1050.0
const MAX_FALL := 360.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.10

const MAX_HP := 6
const ATTACK_DURATION := 0.18
const ATTACK_COOLDOWN := 0.32
const ATTACK_DAMAGE := 2
const ATTACK_KNOCKBACK := 180.0
const INVULN_TIME := 0.8
const HURT_KNOCKBACK := 200.0

var hp := MAX_HP
var facing := 1
var _coyote := 0.0
var _jump_buffer := 0.0
var _attack_timer := 0.0
var _attack_cooldown := 0.0
var _invuln := 0.0
var _hurt_stun := 0.0
var _dead := false

@onready var visual: Polygon2D = $Visual
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_visual: Polygon2D = $AttackHitbox/AttackVisual
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	attack_hitbox.monitoring = false
	attack_visual.visible = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	health_changed.emit(hp, MAX_HP)

func _physics_process(delta: float) -> void:
	if _dead:
		return

	_attack_cooldown = max(0.0, _attack_cooldown - delta)
	_invuln = max(0.0, _invuln - delta)
	if _invuln > 0.0:
		visual.color = Color(1, 1, 1) if int(_invuln * 20) % 2 == 0 else Color(1, 0.4, 0.4)
	else:
		visual.color = Color(1, 1, 1)

	# Timers de saut
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote = max(0.0, _coyote - delta)
	_jump_buffer = max(0.0, _jump_buffer - delta)
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = JUMP_BUFFER

	# Gravite
	if not is_on_floor():
		var g := GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
		velocity.y = min(velocity.y + g * delta, MAX_FALL)

	# Saut (coyote + buffer)
	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer = 0.0
		_coyote = 0.0
		AudioManager.play("jump")
	# Saut variable : relacher coupe l'ascension
	if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY * 0.4:
		velocity.y = JUMP_VELOCITY * 0.4

	# Attaque
	if _attack_timer > 0.0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_end_attack()
	if Input.is_action_just_pressed("attack") and _attack_cooldown <= 0.0 and _attack_timer <= 0.0:
		_start_attack()

	# Orientation selon la visée (stick droit ou souris)
	var aim := _get_aim_dir()
	var aim_facing := 1 if aim.x >= 0.0 else -1
	if aim_facing != facing:
		facing = aim_facing
		_update_facing()

	# Deplacement horizontal
	if _hurt_stun > 0.0:
		_hurt_stun -= delta
	else:
		var dir := Input.get_axis("move_left", "move_right")
		if dir != 0.0:
			var a := ACCEL if is_on_floor() else AIR_ACCEL
			velocity.x = move_toward(velocity.x, dir * SPEED, a * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	move_and_slide()

func _update_facing() -> void:
	visual.scale.x = facing

func _start_attack() -> void:
	_attack_timer = ATTACK_DURATION
	_attack_cooldown = ATTACK_COOLDOWN
	var aim := _get_aim_dir()
	attack_hitbox.position = aim * 16.0
	attack_hitbox.monitoring = true
	attack_visual.visible = true
	# Applique les degats aux hurtbox ennemies en contact
	await get_tree().physics_frame
	if not attack_hitbox.monitoring:
		return
	var hit := false
	for area in attack_hitbox.get_overlapping_areas():
		if area.is_in_group("enemy_hurtbox"):
			var target := area.get_parent()
			if target.has_method("take_damage"):
				target.take_damage(ATTACK_DAMAGE, aim * ATTACK_KNOCKBACK)
				hit = true
	if hit:
		_screen_shake()
		AudioManager.play("hit")

func _end_attack() -> void:
	attack_hitbox.monitoring = false
	attack_visual.visible = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_contact"):
		var src: Node2D = area.get_parent()
		var dmg := 1
		if "contact_damage" in src:
			dmg = int(src.contact_damage)
		take_damage(dmg, src.global_position.x)

func take_damage(amount: int, from_x: float) -> void:
	if _dead or _invuln > 0.0:
		return
	hp = max(0, hp - amount)
	health_changed.emit(hp, MAX_HP)
	_invuln = INVULN_TIME
	var kdir := signf(global_position.x - from_x)
	if kdir == 0.0:
		kdir = -float(facing)
	velocity.x = kdir * HURT_KNOCKBACK
	velocity.y = -120.0
	_hurt_stun = 0.18
	_screen_shake()
	AudioManager.play("hurt")
	if hp <= 0:
		_die()

func _die() -> void:
	_dead = true
	velocity = Vector2.ZERO
	visual.color = Color(0.4, 0.4, 0.4)
	AudioManager.play("gameover")
	died.emit()

func _get_aim_dir() -> Vector2:
	var rx := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var ry := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	var stick := Vector2(rx, ry)
	if stick.length() > 0.2:
		return stick.normalized()
	var to_mouse := get_global_mouse_position() - global_position
	if to_mouse.length_squared() > 0.0:
		return to_mouse.normalized()
	return Vector2(float(facing), 0.0)

func _screen_shake(amount: float = 3.0) -> void:
	var cam := get_node_or_null("Camera2D")
	if cam and cam.has_method("add_trauma"):
		cam.add_trauma(amount)
