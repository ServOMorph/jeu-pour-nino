extends GutTest

const SAVE_PATH := "user://meta_state_test.json"

var ms: Node
var sm: Node

func before_each() -> void:
	ms = load("res://scripts/meta_state.gd").new()
	add_child_autofree(ms)
	sm = load("res://scripts/save_manager.gd").new()
	add_child_autofree(sm)

func after_each() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _write_and_read(meta: Node) -> Node:
	var data: Dictionary = meta.serialize()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	assert_not_null(f)
	f.store_string(JSON.stringify(data))
	f.flush()
	f = null
	var f2 := FileAccess.open(SAVE_PATH, FileAccess.READ)
	assert_not_null(f2)
	var parsed: Variant = JSON.parse_string(f2.get_as_text())
	f2 = null
	var ms2: Node = load("res://scripts/meta_state.gd").new()
	add_child_autofree(ms2)
	if parsed is Dictionary:
		ms2.deserialize(parsed)
	return ms2

func test_save_and_load_preserves_skill_points() -> void:
	ms.add_skill_points(7)
	var loaded := _write_and_read(ms)
	assert_eq(loaded.skill_points, 7)

func test_save_and_load_preserves_grimoire() -> void:
	ms.discover_recipe("corde")
	ms.master_recipe("corde", 0)
	var loaded := _write_and_read(ms)
	assert_true(loaded.is_mastered("corde"))

func test_empty_meta_survives_roundtrip() -> void:
	var loaded := _write_and_read(ms)
	assert_eq(loaded.skill_points, 0)
	assert_true(loaded.grimoire.is_empty())
