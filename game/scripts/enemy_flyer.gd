extends EnemyBase

const SPEED := 55.0
const DETECT_RANGE := 160.0

var _origin := Vector2.ZERO
var _t := 0.0
var _player: Node2D = null

func _on_ready() -> void:
	gravity = 0.0
	_origin = global_position
	_t = randf() * TAU
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_t += delta

	if hit_stun > 0.0:
		hit_stun -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return

	var target := _origin + Vector2(0, sin(_t * 2.0) * 14.0)
	if _player and is_instance_valid(_player):
		var d := global_position.distance_to(_player.global_position)
		if d < DETECT_RANGE:
			target = _player.global_position
	var to_target := (target - global_position)
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
	if visual and abs(velocity.x) > 1.0:
		visual.scale.x = sign(velocity.x)
	move_and_slide()
