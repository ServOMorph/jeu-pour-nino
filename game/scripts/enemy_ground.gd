extends EnemyBase

@export var patrol_range := 60.0
@export var speed := 48.0
@export var max_fall := 380.0
@export var hit_stun_decel := 460.0

var _origin_x := 0.0
var _dir := 1.0
var _started := false

func _get_config_key() -> String:
	return "EnemyGround"

func _on_ready() -> void:
	_load_ground_config()
	_origin_x = global_position.x
	_dir = 1.0 if randf() > 0.5 else -1.0

func _load_ground_config() -> void:
	var cfg := _get_enemy_config()
	if "speed" in cfg:
		speed = float(cfg["speed"])
	if "patrol_range" in cfg:
		patrol_range = float(cfg["patrol_range"])
	if "max_fall" in cfg:
		max_fall = float(cfg["max_fall"])
	if "hit_stun_decel" in cfg:
		hit_stun_decel = float(cfg["hit_stun_decel"])

func _get_visual_state() -> String:
	if _dead:
		return "dead"
	if hit_stun > 0.0:
		return "hurt"
	if abs(velocity.x) > 1.0:
		return "walk"
	return "idle"

func _physics_process(delta: float) -> void:
	if _dead:
		return
	if not _started:
		_origin_x = global_position.x
		_started = true

	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, max_fall)
	else:
		velocity.y = 0.0

	if hit_stun > 0.0:
		hit_stun -= delta
		velocity.x = move_toward(velocity.x, 0.0, hit_stun_decel * delta)
	else:
		# Demi-tour aux bords de patrouille ou contre un mur
		if global_position.x > _origin_x + patrol_range:
			_dir = -1.0
		elif global_position.x < _origin_x - patrol_range:
			_dir = 1.0
		if is_on_wall():
			_dir = -_dir
		velocity.x = _dir * speed
		_set_visual_facing(_dir)

	move_and_slide()
