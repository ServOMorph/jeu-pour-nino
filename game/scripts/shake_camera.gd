extends Camera2D

const DECAY := 6.0
const MAX_OFFSET := Vector2(6, 4)

var trauma := 0.0

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount * 0.12, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(0.0, trauma - DECAY * delta * 0.1)
		var shake := trauma * trauma
		offset = Vector2(
			MAX_OFFSET.x * shake * randf_range(-1.0, 1.0),
			MAX_OFFSET.y * shake * randf_range(-1.0, 1.0)
		)
	else:
		offset = offset.lerp(Vector2.ZERO, 0.3)
