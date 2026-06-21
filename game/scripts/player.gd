extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

const PLAYER_CONFIG  := "res://data/player.json"
const WEAPONS_CONFIG := "res://data/weapons.json"
const ARMOR_CONFIG   := "res://data/armor.json"

var speed            := 130.0
var accel            := 1600.0
var friction         := 1400.0
var air_accel        := 1000.0
var max_fall         := 360.0

var jump_velocity    := -320.0
var gravity          := 800.0
var fall_gravity     := 1050.0
var coyote_time      := 0.10
var jump_buffer_time := 0.10
var jump_cut_factor  := 0.4

var max_hp           := 6
var attack_damage    := 2
var attack_range     := 16.0
var attack_duration  := 0.18
var attack_cooldown  := 0.32
var attack_knockback := 180.0
var screen_shake_hit := 3.0

var hurt_knockback        := 200.0
var hurt_bounce_y         := -120.0
var hurt_stun_dur         := 0.18
var invuln_time           := 0.8
var invuln_flash_rate     := 20
var contact_dmg_default   := 1

var aim_stick_deadzone := 0.2

var damage_reduction := 0

var hp: int
var facing := 1
var _coyote          := 0.0
var _jump_buffer     := 0.0
var _attack_timer    := 0.0
var _attack_cooldown := 0.0
var _invuln          := 0.0
var _hurt_stun       := 0.0
var _dead            := false

var _player_cfg: Dictionary = {}
var _weapon_cfg: Dictionary = {}
var _armor_cfg:  Dictionary = {}

@onready var visual:        Polygon2D = $Visual
@onready var attack_hitbox: Area2D    = $AttackHitbox
@onready var attack_visual: Polygon2D = $AttackHitbox/AttackVisual
@onready var hurtbox:       Area2D    = $Hurtbox

func _ready() -> void:
	_load_configs()
	hp = max_hp
	attack_hitbox.monitoring = false
	attack_visual.visible = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	Inventory.items_changed.connect(_apply_equipment)
	health_changed.emit(hp, max_hp)

func _load_configs() -> void:
	var fp: FileAccess
	var parsed: Variant

	fp = FileAccess.open(PLAYER_CONFIG, FileAccess.READ)
	if fp:
		parsed = JSON.parse_string(fp.get_as_text())
		if parsed is Dictionary:
			_player_cfg = parsed
			var mov: Variant = parsed.get("movement", {})
			if mov is Dictionary:
				if "speed"     in mov: speed     = float(mov["speed"])
				if "accel"     in mov: accel     = float(mov["accel"])
				if "friction"  in mov: friction  = float(mov["friction"])
				if "air_accel" in mov: air_accel = float(mov["air_accel"])
				if "max_fall"  in mov: max_fall  = float(mov["max_fall"])
			var jmp: Variant = parsed.get("jump", {})
			if jmp is Dictionary:
				if "velocity"    in jmp: jump_velocity    = float(jmp["velocity"])
				if "gravity"     in jmp: gravity          = float(jmp["gravity"])
				if "fall_gravity"in jmp: fall_gravity     = float(jmp["fall_gravity"])
				if "coyote_time" in jmp: coyote_time      = float(jmp["coyote_time"])
				if "buffer"      in jmp: jump_buffer_time = float(jmp["buffer"])
				if "cut_factor"  in jmp: jump_cut_factor  = float(jmp["cut_factor"])
			var cbt: Variant = parsed.get("combat", {})
			if cbt is Dictionary:
				if "max_hp"           in cbt: max_hp           = int(cbt["max_hp"])
				if "attack_damage"    in cbt: attack_damage    = int(cbt["attack_damage"])
				if "attack_range"     in cbt: attack_range     = float(cbt["attack_range"])
				if "attack_duration"  in cbt: attack_duration  = float(cbt["attack_duration"])
				if "attack_cooldown"  in cbt: attack_cooldown  = float(cbt["attack_cooldown"])
				if "attack_knockback" in cbt: attack_knockback = float(cbt["attack_knockback"])
				if "screen_shake"     in cbt: screen_shake_hit = float(cbt["screen_shake"])
			var hrt: Variant = parsed.get("hurt", {})
			if hrt is Dictionary:
				if "knockback"           in hrt: hurt_knockback      = float(hrt["knockback"])
				if "bounce_y"            in hrt: hurt_bounce_y       = float(hrt["bounce_y"])
				if "stun"                in hrt: hurt_stun_dur       = float(hrt["stun"])
				if "invuln_time"         in hrt: invuln_time         = float(hrt["invuln_time"])
				if "invuln_flash_rate"   in hrt: invuln_flash_rate   = int(hrt["invuln_flash_rate"])
				if "contact_dmg_default" in hrt: contact_dmg_default = int(hrt["contact_dmg_default"])
			var aim: Variant = parsed.get("aim", {})
			if aim is Dictionary:
				if "stick_deadzone" in aim: aim_stick_deadzone = float(aim["stick_deadzone"])

	fp = FileAccess.open(WEAPONS_CONFIG, FileAccess.READ)
	if fp:
		parsed = JSON.parse_string(fp.get_as_text())
		if parsed is Dictionary:
			_weapon_cfg = parsed

	fp = FileAccess.open(ARMOR_CONFIG, FileAccess.READ)
	if fp:
		parsed = JSON.parse_string(fp.get_as_text())
		if parsed is Dictionary:
			_armor_cfg = parsed

func _physics_process(delta: float) -> void:
	if _dead:
		return

	_attack_cooldown = max(0.0, _attack_cooldown - delta)
	_invuln = max(0.0, _invuln - delta)
	if _invuln > 0.0:
		visual.color = Color(1, 1, 1) if int(_invuln * invuln_flash_rate) % 2 == 0 else Color(1, 0.4, 0.4)
	else:
		visual.color = Color(1, 1, 1)

	if is_on_floor():
		_coyote = coyote_time
	else:
		_coyote = max(0.0, _coyote - delta)
	_jump_buffer = max(0.0, _jump_buffer - delta)
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = jump_buffer_time

	if not is_on_floor():
		var g := gravity if velocity.y < 0.0 else fall_gravity
		velocity.y = min(velocity.y + g * delta, max_fall)

	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
		AudioManager.play("jump")
	if Input.is_action_just_released("jump") and velocity.y < jump_velocity * jump_cut_factor:
		velocity.y = jump_velocity * jump_cut_factor

	if _attack_timer > 0.0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_end_attack()
	if Input.is_action_just_pressed("attack") and _attack_cooldown <= 0.0 and _attack_timer <= 0.0:
		_start_attack()

	var aim := _get_aim_dir()
	var aim_facing := 1 if aim.x >= 0.0 else -1
	if aim_facing != facing:
		facing = aim_facing
		_update_facing()

	if _hurt_stun > 0.0:
		_hurt_stun -= delta
	else:
		var dir := Input.get_axis("move_left", "move_right")
		if dir != 0.0:
			var a := accel if is_on_floor() else air_accel
			velocity.x = move_toward(velocity.x, dir * speed, a * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()

func _update_facing() -> void:
	visual.scale.x = facing

func _start_attack() -> void:
	_attack_timer = attack_duration
	_attack_cooldown = attack_cooldown
	var aim := _get_aim_dir()
	attack_hitbox.position = aim * attack_range
	attack_hitbox.monitoring = true
	attack_visual.visible = true
	await get_tree().physics_frame
	if not attack_hitbox.monitoring:
		return
	var hit := false
	for area in attack_hitbox.get_overlapping_areas():
		if area.is_in_group("enemy_hurtbox") or area.is_in_group("mineable_hurtbox"):
			var target := area.get_parent()
			if target.has_method("take_damage"):
				target.take_damage(attack_damage, aim * attack_knockback)
				hit = true
	if hit:
		_screen_shake(screen_shake_hit)
		AudioManager.play("hit")

func _end_attack() -> void:
	attack_hitbox.monitoring = false
	attack_visual.visible = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_contact"):
		var src: Node2D = area.get_parent()
		var dmg := contact_dmg_default
		if "contact_damage" in src:
			dmg = int(src.contact_damage)
		var knockback := (global_position - src.global_position).normalized()
		take_damage(dmg, knockback)

func take_damage(amount: int, knockback: Vector2) -> void:
	if _dead or _invuln > 0.0:
		return
	hp = max(0, hp - max(1, amount - damage_reduction))
	health_changed.emit(hp, max_hp)
	_invuln = invuln_time
	var dir := knockback if knockback != Vector2.ZERO else Vector2(-float(facing), 0.0)
	velocity.x = dir.normalized().x * hurt_knockback
	velocity.y = hurt_bounce_y
	_hurt_stun = hurt_stun_dur
	_screen_shake(screen_shake_hit)
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
	if stick.length() > aim_stick_deadzone:
		return stick.normalized()
	var to_mouse := get_global_mouse_position() - global_position
	if to_mouse.length_squared() > 0.0:
		return to_mouse.normalized()
	return Vector2(float(facing), 0.0)

func _apply_equipment() -> void:
	var old_max := max_hp
	var cbt: Dictionary = _player_cfg.get("combat", {})
	max_hp        = int(cbt.get("max_hp", max_hp))
	attack_damage = int(cbt.get("attack_damage", attack_damage))
	attack_range  = float(cbt.get("attack_range", attack_range))
	damage_reduction = 0

	for item_id in ["epee_fer", "epee_cuivre"]:
		if Inventory.has_item(item_id) and item_id in _weapon_cfg:
			var w: Dictionary = _weapon_cfg[item_id]
			if "damage" in w: attack_damage = int(w["damage"])
			if "range"  in w: attack_range  = float(w["range"])
			break

	for item_id in _armor_cfg:
		if Inventory.has_item(item_id):
			var a: Dictionary = _armor_cfg[item_id]
			if "max_hp"           in a: max_hp           = int(a["max_hp"])
			if "damage_reduction" in a: damage_reduction += int(a["damage_reduction"])

	var delta_hp := max_hp - old_max
	if delta_hp > 0:
		hp = min(hp + delta_hp, max_hp)
	else:
		hp = min(hp, max_hp)
	health_changed.emit(hp, max_hp)

func _screen_shake(amount: float) -> void:
	var cam := get_node_or_null("Camera2D")
	if cam and cam.has_method("add_trauma"):
		cam.add_trauma(amount)
