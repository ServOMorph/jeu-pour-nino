extends EnemyBase

const SPEED := 38.0

@export var patrol_range := 60.0

var _origin_x := 0.0
var _dir := 1.0
var _started := false

func _on_ready() -> void:
	_origin_x = global_position.x
	_dir = 1.0 if randf() > 0.5 else -1.0

func _physics_process(delta: float) -> void:
	if _dead:
		return
	if not _started:
		_origin_x = global_position.x
		_started = true

	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, 360.0)
	else:
		velocity.y = 0.0

	if hit_stun > 0.0:
		hit_stun -= delta
		velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	else:
		# Demi-tour aux bords de patrouille ou contre un mur
		if global_position.x > _origin_x + patrol_range:
			_dir = -1.0
		elif global_position.x < _origin_x - patrol_range:
			_dir = 1.0
		if is_on_wall():
			_dir = -_dir
		velocity.x = _dir * SPEED
		if visual:
			visual.scale.x = sign(_dir)

	move_and_slide()
