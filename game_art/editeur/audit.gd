extends RefCounted

const AUDIT_EXCLUDED_DIRS := {
	"from_reference": true,
	"generated_raw": true,
	"legacy_archive": true
}

static func run_audit(manifest: Dictionary, animations: Dictionary, assets_root: String) -> Array[Dictionary]:
	var anomalies: Array[Dictionary] = []
	var referenced_assets: Dictionary = {}

	for entity in manifest:
		var manifest_entity: Variant = manifest.get(entity, {})
		if manifest_entity is not Dictionary:
			continue
		var manifest_states: Variant = manifest_entity.get("states", {})
		if manifest_states is not Dictionary:
			continue
		var anim_entity: Variant = animations.get(entity, {})
		var anim_states: Dictionary = {}
		if anim_entity is Dictionary:
			var states_value: Variant = anim_entity.get("states", {})
			if states_value is Dictionary:
				anim_states = states_value
		for state in manifest_states:
			if not anim_states.has(state):
				anomalies.append(_anomaly("error", String(entity), String(state), "etat manquant"))
				continue
			var manifest_state: Variant = manifest_states.get(state, {})
			var anim_state: Variant = anim_states.get(state, {})
			if manifest_state is not Dictionary or anim_state is not Dictionary:
				anomalies.append(_anomaly("error", String(entity), String(state), "configuration d'etat invalide"))
				continue
			_collect_state_anomalies(String(entity), String(state), manifest_state, anim_state, assets_root, referenced_assets, anomalies)

	for asset_path in _list_png_files(assets_root):
		if not referenced_assets.has(asset_path):
			anomalies.append(_anomaly("warning", "", "", "sprite orphelin: " + asset_path))

	for entity in animations:
		var anim_entity: Variant = animations.get(entity, {})
		if anim_entity is not Dictionary:
			continue
		var anim_states: Variant = anim_entity.get("states", {})
		if anim_states is not Dictionary:
			continue
		var placeholders := _detect_placeholders(anim_states, assets_root)
		for message in placeholders:
			anomalies.append(_anomaly("info", String(entity), "", String(message)))

	return anomalies

static func _collect_state_anomalies(entity: String, state: String, manifest_state: Dictionary, anim_state: Dictionary, assets_root: String, referenced_assets: Dictionary, anomalies: Array[Dictionary]) -> void:
	var expected_size := _array_to_size(manifest_state.get("frame_size", []))
	if expected_size == Vector2i.ZERO:
		anomalies.append(_anomaly("error", entity, state, "frame_size manifest invalide"))
		return

	var sheet_value: Variant = anim_state.get("sheet", null)
	if sheet_value is String and not sheet_value.is_empty():
		var sheet_path := _editor_path(String(sheet_value), assets_root)
		referenced_assets[sheet_path] = true
		if not FileAccess.file_exists(sheet_path):
			anomalies.append(_anomaly("error", entity, state, "sprite manquant: " + sheet_path))
			return
		var sheet_size := _image_size(sheet_path)
		if sheet_size == Vector2i.ZERO:
			anomalies.append(_anomaly("error", entity, state, "lecture image impossible: " + sheet_path))
			return
		var anim_frame_size := _array_to_size(anim_state.get("frame_size", []))
		if anim_frame_size != expected_size:
			anomalies.append(_anomaly("warning", entity, state, "frame_size animation != manifest"))
		if sheet_size.x % expected_size.x != 0 or sheet_size.y % expected_size.y != 0:
			anomalies.append(_anomaly("warning", entity, state, "grille sheet non entiere pour " + sheet_path))
			return
		var cols := sheet_size.x / expected_size.x
		var rows := sheet_size.y / expected_size.y
		var frame_count := cols * rows
		var frames: Variant = anim_state.get("frames", [])
		if frames is Array:
			for frame_idx in frames:
				var idx := int(frame_idx)
				if idx < 0 or idx >= frame_count:
					anomalies.append(_anomaly("warning", entity, state, "indice frame hors grille: " + str(idx)))
	else:
		var frames: Variant = anim_state.get("frames", [])
		if frames is not Array or frames.is_empty():
			anomalies.append(_anomaly("error", entity, state, "aucune frame declaree"))
			return
		for frame_path in frames:
			var asset_path := _editor_path(String(frame_path), assets_root)
			referenced_assets[asset_path] = true
			if not FileAccess.file_exists(asset_path):
				anomalies.append(_anomaly("error", entity, state, "sprite manquant: " + asset_path))
				continue
			var frame_size := _image_size(asset_path)
			if frame_size == Vector2i.ZERO:
				anomalies.append(_anomaly("error", entity, state, "lecture image impossible: " + asset_path))
				continue
			if frame_size != expected_size:
				anomalies.append(_anomaly("warning", entity, state, "taille incoherente: %s = %dx%d, attendu %dx%d" % [
					asset_path, frame_size.x, frame_size.y, expected_size.x, expected_size.y
				]))

static func _detect_placeholders(anim_states: Dictionary, assets_root: String) -> Array[String]:
	var states_by_asset: Dictionary = {}
	for state in anim_states:
		var cfg: Variant = anim_states.get(state, {})
		if cfg is not Dictionary:
			continue
		var asset_key := _placeholder_asset_key(cfg, assets_root)
		if asset_key.is_empty():
			continue
		if not states_by_asset.has(asset_key):
			states_by_asset[asset_key] = []
		states_by_asset[asset_key].append(String(state))
	var messages: Array[String] = []
	for asset_key in states_by_asset:
		var state_names: Array = states_by_asset[asset_key]
		if state_names.size() > 1:
			messages.append("placeholder detecte: %s partage par [%s]" % [
				asset_key, ", ".join(state_names)
			])
	return messages

static func _placeholder_asset_key(cfg: Dictionary, assets_root: String) -> String:
	var sheet_value: Variant = cfg.get("sheet", null)
	if sheet_value is String and not sheet_value.is_empty():
		var frames: Variant = cfg.get("frames", [])
		if frames is Array and frames.size() == 1:
			return _editor_path(String(sheet_value), assets_root) + "#" + str(int(frames[0]))
		return ""
	var frames: Variant = cfg.get("frames", [])
	if frames is Array and frames.size() == 1 and frames[0] is String:
		return _editor_path(String(frames[0]), assets_root)
	return ""

static func _array_to_size(value: Variant) -> Vector2i:
	if value is Array and value.size() >= 2:
		var w := int(value[0])
		var h := int(value[1])
		if w > 0 and h > 0:
			return Vector2i(w, h)
	return Vector2i.ZERO

static func _image_size(path: String) -> Vector2i:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null or img.is_empty():
		return Vector2i.ZERO
	return img.get_size()

static func _list_png_files(root: String) -> Array[String]:
	var results: Array[String] = []
	_walk_png(root.trim_suffix("/"), results)
	return results

static func _walk_png(dir_path: String, results: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "":
			break
		if name == "." or name == "..":
			continue
		var child := dir_path + "/" + name
		if dir.current_is_dir():
			if AUDIT_EXCLUDED_DIRS.has(name):
				continue
			_walk_png(child, results)
		elif name.to_lower().ends_with(".png"):
			results.append(child)
	dir.list_dir_end()

static func _editor_path(path: String, assets_root: String) -> String:
	return path.replace("res://assets/sprites/", assets_root.trim_suffix("/") + "/")

static func _anomaly(severity: String, entity: String, state: String, message: String) -> Dictionary:
	return {
		"severity": severity,
		"entity": entity,
		"state": state,
		"message": message
	}
