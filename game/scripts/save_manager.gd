extends Node

const SAVE_PATH := "user://meta_state.json"

func _ready() -> void:
	load_meta()

func save_meta() -> void:
	var data := MetaState.serialize()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: impossible d'ouvrir %s en ecriture" % SAVE_PATH)
		return
	f.store_string(JSON.stringify(data, "\t"))

func load_meta() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		push_error("SaveManager: impossible d'ouvrir %s en lecture" % SAVE_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		MetaState.deserialize(parsed)
	else:
		push_error("SaveManager: fichier de sauvegarde corrompu")

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
