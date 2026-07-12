extends Area2D

var direction := Vector2.RIGHT
var speed := 400.0
var damage := 3
var max_range := 800.0

var _traveled := 0.0

func _ready() -> void:
	rotation = direction.angle()
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var step := direction * speed * delta
	global_position += step
	_traveled += step.length()
	if _traveled >= max_range:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox") or area.is_in_group("mineable_hurtbox"):
		var target := area.get_parent()
		if target.has_method("take_damage"):
			target.take_damage(damage, direction * 120.0)
		queue_free()
