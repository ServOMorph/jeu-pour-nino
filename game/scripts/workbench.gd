extends StaticBody2D

signal interact_requested

const SIZE := Vector2(80, 72)
const ZONE_SIZE := Vector2(240, 200)
const WORKBENCH_TEXTURE_PATH := "res://assets/sprites/objects/workbench.png"

@export var workbench_tier := 1

var _in_range := false
var _prompt: Label

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = SIZE
	shape.shape = rs
	add_child(shape)

	var body_vis := Sprite2D.new()
	var image := Image.load_from_file(ProjectSettings.globalize_path(WORKBENCH_TEXTURE_PATH))
	if image != null and not image.is_empty():
		body_vis.texture = ImageTexture.create_from_image(image)
	add_child(body_vis)

	var zone := Area2D.new()
	zone.collision_layer = 0
	zone.collision_mask = 2
	var zshape := CollisionShape2D.new()
	var zrs := RectangleShape2D.new()
	zrs.size = ZONE_SIZE
	zshape.shape = zrs
	zone.add_child(zshape)
	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)
	add_child(zone)

	_prompt = Label.new()
	_prompt.text = "Y : crafter"
	_prompt.add_theme_font_size_override("font_size", 32)
	_prompt.position = Vector2(-72, -88)
	_prompt.visible = false
	add_child(_prompt)

func _process(_delta: float) -> void:
	if _in_range and Input.is_action_just_pressed("interact"):
		interact_requested.emit()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = true
		_prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = false
		_prompt.visible = false
