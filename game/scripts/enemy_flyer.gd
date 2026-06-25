extends EnemyBase

@export var speed := 65.0
@export var detect_range := 190.0
@export var hover_amplitude := 14.0
@export var hover_speed := 2.0
@export var hit_stun_decel := 650.0

var _origin := Vector2.ZERO
var _t := 0.0
var _player: Node2D = null

func _get_config_key() -> String:
	return "EnemyFlyer"

func _on_ready() -> void:
	_load_flyer_config()
	gravity = 0.0
	_origin = global_position
	_t = randf() * TAU
	_player = get_tree().get_first_node_in_group("player")

func _load_flyer_config() -> void:
	var cfg := _get_enemy_config()
	if "speed" in cfg:
		speed = float(cfg["speed"])
	if "detect_range" in cfg:
		detect_range = float(cfg["detect_range"])
	if "hover_amplitude" in cfg:
		hover_amplitude = float(cfg["hover_amplitude"])
	if "hover_speed" in cfg:
		hover_speed = float(cfg["hover_speed"])
	if "hit_stun_decel" in cfg:
		hit_stun_decel = float(cfg["hit_stun_decel"])

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_t += delta

	if hit_stun > 0.0:
		hit_stun -= delta
		velocity = velocity.move_toward(Vector2.ZERO, hit_stun_decel * delta)
		move_and_slide()
		return

	var target := _origin + Vector2(0, sin(_t * hover_speed) * hover_amplitude)
	if _player and is_instance_valid(_player):
		var d := global_position.distance_to(_player.global_position)
		if d < detect_range:
			target = _player.global_position
	var to_target := (target - global_position)
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * speed
	else:
		velocity = Vector2.ZERO
	if visual and abs(velocity.x) > 1.0:
		visual.scale.x = sign(velocity.x)
	move_and_slide()
