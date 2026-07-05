extends SceneTree

func _initialize() -> void:
	var MainScript := load("res://editeur/main.gd")
	var main: Control = MainScript.new()
	get_root().add_child(main)
	main._ready()

	main._refresh_audit()
	if main._last_audit_results.is_empty():
		push_error("audit vide inattendu")
		quit(1)
		return

	main._export_audit_report()
	if not FileAccess.file_exists("res://audit_report.md"):
		push_error("rapport non exporte")
		quit(1)
		return

	var entity_item := _find_tree_item(main._audit_tree, "player", "jump")
	if entity_item == null:
		push_error("anomalie player/jump introuvable")
		quit(1)
		return
	main._audit_tree.set_selected(entity_item, 0)
	main._on_audit_item_activated()

	var ok: bool = main._current_entity == "player" and main._driver.animation == "jump"
	print("audit_ui_select=", ok)
	quit(0 if ok else 1)

func _find_tree_item(tree: Tree, entity: String, state: String) -> TreeItem:
	var root := tree.get_root()
	if root == null:
		return null
	var item := root.get_first_child()
	while item != null:
		if item.get_text(1) == entity and item.get_text(2) == state:
			return item
		item = item.get_next()
	return null
