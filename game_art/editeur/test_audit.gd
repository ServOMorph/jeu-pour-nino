extends SceneTree

const AuditScript := preload("res://editeur/audit.gd")
const MANIFEST_PATH := "res://data/manifest.json"
const ANIMATIONS_PATH := "res://data/animations.json"
const ORPHAN_PATH := "res://assets/test_orphan_audit.png"

func _initialize() -> void:
	var manifest := _load_json(MANIFEST_PATH)
	var animations := _load_json(ANIMATIONS_PATH)
	if manifest.is_empty() or animations.is_empty():
		push_error("chargement manifest/animations impossible")
		quit(1)
		return

	_create_orphan_png()

	var mutated_manifest: Dictionary = manifest.duplicate(true)
	var mutated_animations: Dictionary = animations.duplicate(true)
	mutated_animations["enemy_ground"]["states"].erase("walk")
	mutated_animations["player"]["states"]["jump"]["frames"] = ["res://assets/sprites/player/introuvable.png"]
	mutated_manifest["player"]["states"]["run"]["frame_size"] = [14, 24]
	mutated_animations["player"]["states"]["run"]["frames"] = [999]

	var anomalies: Array[Dictionary] = AuditScript.run_audit(mutated_manifest, mutated_animations, "res://assets")
	_delete_orphan_png()

	var checks := {
		"etat manquant": false,
		"sprite manquant": false,
		"sprite orphelin": false,
		"indice frame hors grille": false,
		"placeholder detecte": false
	}

	for anomaly in anomalies:
		var message := String(anomaly.get("message", ""))
		for key in checks:
			if message.contains(key):
				checks[key] = true

	for key in checks:
		print(key + "=", checks[key])
		if not checks[key]:
			quit(1)
			return

	quit(0)

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _create_orphan_png() -> void:
	var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	img.save_png(ProjectSettings.globalize_path(ORPHAN_PATH))

func _delete_orphan_png() -> void:
	if FileAccess.file_exists(ORPHAN_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ORPHAN_PATH))
