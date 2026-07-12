extends RefCounted
class_name EditorPathUtils

static func editor_path(path: String) -> String:
	return path.replace("res://assets/sprites/", "res://assets/")
