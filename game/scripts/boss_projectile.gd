extends Area2D

const BOSS_CONFIG_FILE := "res://data/boss.json"

var speed := 110.0
var lifetime := 4.0
var damage := 1

var direction := Vector2.RIGHT
var _life := 0.0

func _load_config() -> void:
	var f := FileAccess.open(BOSS_CONFIG_FILE, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not parsed is Dictionary:
		return
	var cfg: Variant = parsed.get("BossProjectile", null)
	if not cfg is Dictionary:
		return
	if "speed" in cfg:    speed = float(cfg["speed"])
	if "lifetime" in cfg: lifetime = float(cfg["lifetime"])
	if "damage" in cfg:   damage = int(cfg["damage"])

func _ready() -> void:
	_load_config()
	_life = lifetime
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player := area.get_parent()
		if player.has_method("take_damage"):
			player.take_damage(damage, direction)
		queue_free()
