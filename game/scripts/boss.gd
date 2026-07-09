extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

const BOSS_CONFIG_FILE := "res://data/boss.json"

const PROJECTILE := preload("res://scenes/enemies/boss_projectile.tscn")
const PROJECTILE_MUZZLE_OFFSET := Vector2(0.0, -82.0)

enum State { SLEEP, IDLE, CHARGE, VOLLEY, SLAM_RISE, SLAM_FALL, PAUSE }

var max_hp         := 40
var contact_damage := 2
var attack_count   := 3

var gravity        := 800.0
var max_fall       := 400.0
var idle_decel     := 300.0
var slam_rise_decel := 200.0
var pause_decel    := 300.0

var charge_speed   := 150.0
var charge_min_dist := 60.0
var dur_charge     := 1.2

var slam_jump_velocity := -260.0
var slam_fall_velocity :=  700.0
var slam_hit_range     :=   70.0
var slam_trauma        :=    6.0
var dur_slam_rise      :=    0.5
var dur_slam_pause     :=    0.8

var volley_count       := 3
var volley_spread_deg  := 18.0
var dur_volley         := 0.5
var dur_volley_pause   := 0.7

var dur_idle           := 0.5
var dur_attack_pause   := 0.6

var flash_duration     := 0.1
var flash_modulate     := 2.5
var hp := 0
var state: int = State.SLEEP
var _state_time := 0.0
var _flash := 0.0
var _player: Node2D = null
var _facing := -1.0
var _slam_origin_y := 0.0

@onready var visual = $Visual
@onready var hurtbox: Area2D = $Hurtbox

func _load_config() -> void:
	var f := FileAccess.open(BOSS_CONFIG_FILE, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is not Dictionary:
		return
	var cfg: Variant = parsed.get("Boss", null)
	if cfg is not Dictionary:
		return
	if "max_hp"         in cfg: max_hp         = int(cfg["max_hp"])
	if "contact_damage" in cfg: contact_damage = int(cfg["contact_damage"])
	if "attack_count"   in cfg: attack_count   = int(cfg["attack_count"])
	var phy: Variant = cfg.get("physics", {})
	if phy is Dictionary:
		if "gravity"         in phy: gravity         = float(phy["gravity"])
		if "max_fall"        in phy: max_fall        = float(phy["max_fall"])
		if "idle_decel"      in phy: idle_decel      = float(phy["idle_decel"])
		if "slam_rise_decel" in phy: slam_rise_decel = float(phy["slam_rise_decel"])
		if "pause_decel"     in phy: pause_decel     = float(phy["pause_decel"])
	var chg: Variant = cfg.get("charge", {})
	if chg is Dictionary:
		if "speed"    in chg: charge_speed    = float(chg["speed"])
		if "min_dist" in chg: charge_min_dist = float(chg["min_dist"])
		if "duration" in chg: dur_charge      = float(chg["duration"])
	var slm: Variant = cfg.get("slam", {})
	if slm is Dictionary:
		if "jump_velocity"   in slm: slam_jump_velocity = float(slm["jump_velocity"])
		if "fall_velocity"   in slm: slam_fall_velocity = float(slm["fall_velocity"])
		if "hit_range"       in slm: slam_hit_range     = float(slm["hit_range"])
		if "trauma"          in slm: slam_trauma        = float(slm["trauma"])
		if "rise_duration"   in slm: dur_slam_rise      = float(slm["rise_duration"])
		if "pause_duration"  in slm: dur_slam_pause     = float(slm["pause_duration"])
	var vol: Variant = cfg.get("volley", {})
	if vol is Dictionary:
		if "count"           in vol: volley_count      = int(vol["count"])
		if "spread_deg"      in vol: volley_spread_deg = float(vol["spread_deg"])
		if "duration"        in vol: dur_volley        = float(vol["duration"])
		if "pause_duration"  in vol: dur_volley_pause  = float(vol["pause_duration"])
	var dur: Variant = cfg.get("durations", {})
	if dur is Dictionary:
		if "idle"         in dur: dur_idle         = float(dur["idle"])
		if "attack_pause" in dur: dur_attack_pause = float(dur["attack_pause"])
	var fl: Variant = cfg.get("flash", {})
	if fl is Dictionary:
		if "duration" in fl: flash_duration = float(fl["duration"])
		if "modulate" in fl: flash_modulate = float(fl["modulate"])

func _ready() -> void:
	_load_config()
	hp = max_hp
	hurtbox.add_to_group("enemy_hurtbox")
	_player = get_tree().get_first_node_in_group("player")
	set_physics_process(false)
	_update_visual()

func activate() -> void:
	_player = get_tree().get_first_node_in_group("player")
	health_changed.emit(hp, max_hp)
	_set_state(State.IDLE, dur_idle)
	set_physics_process(true)
	AudioManager.play("boss")

func take_damage(amount: int, knockback: Vector2) -> void:
	if state == State.SLEEP:
		return
	hp = max(0, hp - amount)
	_flash = flash_duration
	health_changed.emit(hp, max_hp)
	if hp <= 0:
		_die()

func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash -= delta
		visual.modulate = Color(flash_modulate, flash_modulate, flash_modulate)
	else:
		visual.modulate = Color(1, 1, 1)
	_update_visual()

func _physics_process(delta: float) -> void:
	if not is_on_floor() and state != State.SLAM_RISE:
		velocity.y = min(velocity.y + gravity * delta, max_fall)
	if is_on_floor() and state not in [State.SLAM_RISE, State.SLAM_FALL]:
		velocity.y = 0.0

	if _player and is_instance_valid(_player):
		_facing = sign(_player.global_position.x - global_position.x)
		if _facing == 0:
			_facing = -1.0
		_update_facing()

	_state_time -= delta

	match state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, idle_decel * delta)
			if _state_time <= 0.0:
				_choose_attack()
		State.CHARGE:
			velocity.x = 0.0
			if is_on_wall() or _state_time <= 0.0:
				_set_state(State.PAUSE, dur_attack_pause)
		State.VOLLEY:
			if _state_time <= 0.0:
				_set_state(State.PAUSE, dur_volley_pause)
		State.SLAM_RISE:
			velocity.x = move_toward(velocity.x, 0.0, slam_rise_decel * delta)
			if _state_time <= 0.0:
				velocity.y = slam_fall_velocity
				_set_state(State.SLAM_FALL)
		State.SLAM_FALL:
			velocity.x = 0.0
			if is_on_floor():
				_slam_impact()
				_set_state(State.PAUSE, dur_slam_pause)
		State.PAUSE:
			velocity.x = move_toward(velocity.x, 0.0, pause_decel * delta)
			if _state_time <= 0.0:
				_set_state(State.IDLE, dur_idle)

	velocity.x = 0.0
	move_and_slide()

func _update_facing() -> void:
	if visual and visual.has_method("set_facing"):
		visual.set_facing(int(_facing))

func _update_visual() -> void:
	if visual and visual.has_method("play_state"):
		visual.play_state(_get_visual_state())

func _get_visual_state() -> String:
	if hp <= 0:
		return "dead"
	match state:
		State.SLEEP:
			return "sleep"
		State.IDLE:
			return "idle"
		State.CHARGE:
			return "charge"
		State.VOLLEY:
			return "volley"
		State.SLAM_RISE:
			return "slam_rise"
		State.SLAM_FALL:
			return "slam_fall"
		State.PAUSE:
			return "pause"
	return "hurt" if _flash > 0.0 else "idle"

func _set_state(s: int, duration: float = 0.6) -> void:
	state = s
	_state_time = duration

func _choose_attack() -> void:
	var dist := 9999.0
	if _player and is_instance_valid(_player):
		dist = abs(_player.global_position.x - global_position.x)
	var roll := randi() % attack_count
	if roll == 0 and dist > charge_min_dist:
		_set_state(State.CHARGE, dur_charge)
	elif roll == 1:
		_fire_volley()
		_set_state(State.VOLLEY, dur_volley)
	else:
		velocity.y = slam_jump_velocity
		_set_state(State.SLAM_RISE, dur_slam_rise)

func _fire_volley() -> void:
	if not (_player and is_instance_valid(_player)):
		return
	var muzzle_origin := global_position + PROJECTILE_MUZZLE_OFFSET
	var target_pos := _player.global_position
	var shot_dir := (target_pos - muzzle_origin).normalized()
	print("[boss] fire_volley origin=", muzzle_origin)
	var p := PROJECTILE.instantiate()
	get_parent().add_child(p)
	p.direction = shot_dir
	p.global_position = muzzle_origin + shot_dir * 28.0

func _slam_impact() -> void:
	if _player and is_instance_valid(_player):
		var cam = _player.get_node_or_null("Camera2D")
		if cam and cam.has_method("add_trauma"):
			cam.add_trauma(slam_trauma)
	if _player and is_instance_valid(_player):
		var dx: float = abs(_player.global_position.x - global_position.x)
		if dx < slam_hit_range and _player.has_method("take_damage"):
			if _player.is_on_floor():
				var dir := (_player.global_position - global_position).normalized()
				_player.take_damage(contact_damage, dir)

func _die() -> void:
	state = State.SLEEP
	set_physics_process(false)
	visual.modulate = Color(0.3, 0.2, 0.35)
	_update_visual()
	AudioManager.play("victory")
	died.emit()
	queue_free()
