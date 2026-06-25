extends AnimatedSprite2D
class_name AnimationDriver

const ANIMATION_CONFIG := "res://data/animations.json"

@export var entity_key := ""

var _default_state := ""
var _state_configs: Dictionary = {}
var _current_state := ""

func _ready() -> void:
	_load_config()
	if not _default_state.is_empty():
		play_state(_default_state)

func play_state(state: String, speed_multiplier: float = 1.0) -> void:
	var target_state := state
	if not _state_configs.has(target_state):
		target_state = _default_state
	if target_state.is_empty():
		return
	var state_cfg: Dictionary = _state_configs.get(target_state, {})
	if target_state != _current_state:
		_current_state = target_state
		_apply_offset(state_cfg)
		play(target_state)
	speed_scale = speed_multiplier

func set_facing(direction: int) -> void:
	flip_h = direction < 0

func _load_config() -> void:
	if entity_key.is_empty():
		return
	var file := FileAccess.open(ANIMATION_CONFIG, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		return
	var entity_cfg: Variant = parsed.get(entity_key, null)
	if entity_cfg is not Dictionary:
		return
	_default_state = String(entity_cfg.get("default_state", ""))
	_state_configs = entity_cfg.get("states", {})
	sprite_frames = SpriteFrames.new()
	for state_name in _state_configs:
		var state_cfg: Variant = _state_configs[state_name]
		if state_cfg is not Dictionary:
			continue
		var fps := float(state_cfg.get("fps", 1.0))
		var loop := bool(state_cfg.get("loop", true))
		var frames: Variant = state_cfg.get("frames", [])
		sprite_frames.add_animation(state_name)
		sprite_frames.set_animation_speed(state_name, fps)
		sprite_frames.set_animation_loop(state_name, loop)
		if frames is Array:
			for frame_path in frames:
				var texture := _load_texture(String(frame_path))
				if texture is Texture2D:
					sprite_frames.add_frame(state_name, texture)

func _apply_offset(state_cfg: Dictionary) -> void:
	var offset_cfg: Variant = state_cfg.get("offset", [0.0, 0.0])
	if offset_cfg is Array and offset_cfg.size() >= 2:
		offset = Vector2(float(offset_cfg[0]), float(offset_cfg[1]))

func _load_texture(frame_path: String) -> Texture2D:
	if not frame_path.begins_with("res://"):
		var texture := load(frame_path)
		return texture if texture is Texture2D else null
	var ext := frame_path.get_extension().to_lower()
	if ext not in ["png", "webp"]:
		var imported_texture := load(frame_path)
		return imported_texture if imported_texture is Texture2D else null
	var image := Image.load_from_file(ProjectSettings.globalize_path(frame_path))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)
