extends Area2D

const SPEED := 110.0
const LIFETIME := 4.0
const DAMAGE := 1

var direction := Vector2.RIGHT
var _life := LIFETIME

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player := area.get_parent()
		if player.has_method("take_damage"):
			player.take_damage(DAMAGE, global_position.x)
		queue_free()
