extends Area2D

signal interact_requested

const ZONE_SIZE := Vector2(260, 260)

var label_text := "ENTRER"
var color := Color(0.4, 0.8, 0.7)
var locked := false

var _in_range := false
var _prompt: Label

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = ZONE_SIZE
	shape.shape = rs
	add_child(shape)

	_prompt = Label.new()
	_prompt.text = "Y : entrer" if not locked else "EN CONSTRUCTION"
	_prompt.add_theme_font_size_override("font_size", 28)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.position = Vector2(-160, -140)
	_prompt.size = Vector2(320, 40)
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _in_range and not locked and Input.is_action_just_pressed("interact"):
		interact_requested.emit()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = true
		_prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = false
		_prompt.visible = false
