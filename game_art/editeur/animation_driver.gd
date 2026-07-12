extends AnimatedSprite2D
class_name AnimationDriverEditor

const ANIMATION_CONFIG := "res://data/animations.json"
const PathUtilsScript := preload("res://editeur/path_utils.gd")

var entity_key := ""
var _state_configs: Dictionary = {}

func load_entity(key: String) -> void:
	entity_key = key
	var file := FileAccess.open(ANIMATION_CONFIG, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		return
	var entity_cfg: Variant = parsed.get(entity_key, null)
	if entity_cfg is not Dictionary:
		return
	_build_sprite_frames(entity_cfg)

func load_from_dict(entity_cfg: Dictionary) -> void:
	_build_sprite_frames(entity_cfg)

func play_state(state: String) -> void:
	if not _state_configs.has(state):
		return
	var cfg: Dictionary = _state_configs[state]
	_apply_offset(cfg)
	play(state)

func get_current_state_cfg() -> Dictionary:
	return _state_configs.get(animation, {})

func get_sheet_frame_count(sheet_path: String, frame_size: Array) -> int:
	if frame_size.size() < 2:
		return 0
	var tex := _load_tex(_editor_path(sheet_path))
	if tex == null:
		return 0
	var fw := int(frame_size[0])
	var fh := int(frame_size[1])
	if fw <= 0 or fh <= 0:
		return 0
	return (tex.get_width() / fw) * (tex.get_height() / fh)

func _build_sprite_frames(entity_cfg: Dictionary) -> void:
	_state_configs = entity_cfg.get("states", {})
	sprite_frames = SpriteFrames.new()
	for state_name in _state_configs:
		var cfg: Variant = _state_configs[state_name]
		if cfg is not Dictionary:
			continue
		var fps := float(cfg.get("fps", 1.0))
		var loop := bool(cfg.get("loop", true))
		var frames: Variant = cfg.get("frames", [])
		sprite_frames.add_animation(state_name)
		sprite_frames.set_animation_speed(state_name, fps)
		sprite_frames.set_animation_loop(state_name, loop)
		var sheet: Variant = cfg.get("sheet", null)
		if sheet is String and not sheet.is_empty():
			var fsz: Variant = cfg.get("frame_size", [16, 16])
			var fw := int(fsz[0]) if fsz is Array and fsz.size() >= 2 else 16
			var fh := int(fsz[1]) if fsz is Array and fsz.size() >= 2 else 16
			var tex := _load_tex(_editor_path(sheet))
			if frames is Array:
				if tex is Texture2D:
					var cols := tex.get_width() / fw
					for idx in frames:
						var atlas := AtlasTexture.new()
						atlas.atlas = tex
						atlas.region = Rect2(int(idx) % cols * fw, int(idx) / cols * fh, fw, fh)
						sprite_frames.add_frame(state_name, atlas)
				else:
					var placeholder := _placeholder_tex(fw, fh)
					for idx in frames:
						sprite_frames.add_frame(state_name, placeholder)
		elif frames is Array:
			for fp in frames:
				var tex := _load_tex(_editor_path(String(fp)))
				if tex is Texture2D:
					sprite_frames.add_frame(state_name, tex)
				else:
					sprite_frames.add_frame(state_name, _placeholder_tex(16, 16))

func _editor_path(path: String) -> String:
	return PathUtilsScript.editor_path(path)

func _apply_offset(cfg: Dictionary) -> void:
	var o: Variant = cfg.get("offset", [0.0, 0.0])
	if o is Array and o.size() >= 2:
		offset = Vector2(float(o[0]), float(o[1]))

func _load_tex(path: String) -> Texture2D:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null or img.is_empty():
		push_warning("sprite manquant: " + path)
		return null
	return ImageTexture.create_from_image(img)

func _placeholder_tex(w: int, h: int) -> Texture2D:
	var img := Image.create(max(w, 1), max(h, 1), false, Image.FORMAT_RGB8)
	for y in img.get_height():
		for x in img.get_width():
			var even := ((x / 4) + (y / 4)) % 2 == 0
			img.set_pixel(x, y, Color.MAGENTA if even else Color.BLACK)
	return ImageTexture.create_from_image(img)
