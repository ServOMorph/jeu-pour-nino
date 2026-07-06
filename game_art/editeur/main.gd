extends VBoxContainer

const ANIM_CONFIG := "res://data/animations.json"
const MANIFEST_CONFIG := "res://data/manifest.json"
const AUDIT_REPORT_PATH := "res://audit_report.md"
const REFERENCE_ROOT := "res://assets/from_reference/"
const SPECS_DIR := "res://specs"
const AnimationDriverEditorScript := preload("res://editeur/animation_driver.gd")
const InspectorScript := preload("res://editeur/inspector.gd")
const AuditScript := preload("res://editeur/audit.gd")

var _entity_list: ItemList
var _state_list: ItemList
var _gallery_panel: Control
var _inspector_panel: Control
var _preview_row: HBoxContainer
var _preview_container: SubViewportContainer
var _viewport: SubViewport
var _reference_preview_container: SubViewportContainer
var _reference_viewport: SubViewport
var _reference_texture_rect: TextureRect
var _driver: AnimationDriverEditorScript
var _inspector: InspectorScript
var _frame_info_label: Label
var _btn_pause: Button
var _audit_dialog: AcceptDialog
var _audit_tree: Tree
var _audit_status_label: Label
var _entities: Dictionary = {}
var _current_entity := ""
var _paused := false
var _zoom := 3.0
var _dirty := false
var _last_audit_results: Array[Dictionary] = []

const WINDOW_TITLE := "Editeur game_art"
const BASE_PREVIEW_SIZE := 200.0
const MIN_SIDE_PANEL_WIDTH := 140.0
const MIN_PREVIEW_SIZE := 120.0

func _ready() -> void:
	_build_ui()
	_load_entities()
	_update_title()
	_update_preview_size()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_preview_size()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.ctrl_pressed and event.keycode == KEY_S:
		_save()
		get_viewport().set_input_as_handled()

func _build_ui() -> void:
	_build_toolbar(self)
	_build_audit_dialog()

	var hsplit_outer := HSplitContainer.new()
	hsplit_outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(hsplit_outer)

	_build_gallery_panel(hsplit_outer)

	var hsplit_inner := HSplitContainer.new()
	hsplit_inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hsplit_outer.add_child(hsplit_inner)

	_build_preview_panel(hsplit_inner)
	_build_inspector_panel(hsplit_inner)

func _build_toolbar(parent: Control) -> void:
	var bar := HBoxContainer.new()
	parent.add_child(bar)

	var lbl := Label.new()
	lbl.text = "Zoom : "
	bar.add_child(lbl)

	for z in [1, 3, 6, 8]:
		var btn := Button.new()
		btn.text = "x%d" % z
		var zf := float(z)
		btn.pressed.connect(func(): _set_zoom(zf))
		bar.add_child(btn)

	bar.add_child(VSeparator.new())

	var btn_prev := Button.new()
	btn_prev.text = "|<"
	btn_prev.pressed.connect(_prev_frame)
	bar.add_child(btn_prev)

	_btn_pause = Button.new()
	_btn_pause.text = "II"
	_btn_pause.pressed.connect(_toggle_pause)
	bar.add_child(_btn_pause)

	var btn_next := Button.new()
	btn_next.text = ">|"
	btn_next.pressed.connect(_next_frame)
	bar.add_child(btn_next)

	bar.add_child(VSeparator.new())

	var btn_save := Button.new()
	btn_save.text = "Sauvegarder"
	btn_save.pressed.connect(_save)
	bar.add_child(btn_save)

	var btn_audit := Button.new()
	btn_audit.text = "Audit"
	btn_audit.pressed.connect(_open_audit_dialog)
	bar.add_child(btn_audit)

	var btn_specs := Button.new()
	btn_specs.text = "Specs"
	btn_specs.pressed.connect(_export_entity_specs)
	bar.add_child(btn_specs)

func _build_gallery_panel(parent: Control) -> void:
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(MIN_SIDE_PANEL_WIDTH, 0)
	parent.add_child(panel)
	_gallery_panel = panel

	var lbl_e := Label.new()
	lbl_e.text = "Entite"
	panel.add_child(lbl_e)

	_entity_list = ItemList.new()
	_entity_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_entity_list.item_selected.connect(_on_entity_selected)
	panel.add_child(_entity_list)

	var lbl_s := Label.new()
	lbl_s.text = "Etat"
	panel.add_child(lbl_s)

	_state_list = ItemList.new()
	_state_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_state_list.item_selected.connect(_on_state_selected)
	panel.add_child(_state_list)

func _build_preview_panel(parent: Control) -> void:
	var panel := VBoxContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var preview_scroll := ScrollContainer.new()
	preview_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	preview_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	panel.add_child(preview_scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_scroll.add_child(center)

	_preview_row = HBoxContainer.new()
	_preview_row.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(_preview_row)

	var produced_column := VBoxContainer.new()
	_preview_row.add_child(produced_column)

	var produced_label := Label.new()
	produced_label.text = "Produit"
	produced_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	produced_column.add_child(produced_label)

	_preview_container = SubViewportContainer.new()
	_preview_container.stretch = true
	_preview_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	produced_column.add_child(_preview_container)

	_viewport = SubViewport.new()
	_viewport.size = Vector2i(200, 200)
	_viewport.transparent_bg = true
	_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_preview_container.add_child(_viewport)

	var checker := TextureRect.new()
	checker.texture = _build_checker_texture()
	checker.stretch_mode = TextureRect.STRETCH_TILE
	checker.size = Vector2(200, 200)
	_viewport.add_child(checker)

	_driver = AnimationDriverEditorScript.new()
	_viewport.add_child(_driver)
	_driver.frame_changed.connect(_update_frame_info)

	var reference_column := VBoxContainer.new()
	_preview_row.add_child(reference_column)

	var reference_label := Label.new()
	reference_label.text = "Reference"
	reference_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reference_column.add_child(reference_label)

	_reference_preview_container = SubViewportContainer.new()
	_reference_preview_container.stretch = true
	_reference_preview_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	reference_column.add_child(_reference_preview_container)

	_reference_viewport = SubViewport.new()
	_reference_viewport.size = Vector2i(200, 200)
	_reference_viewport.transparent_bg = true
	_reference_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_reference_preview_container.add_child(_reference_viewport)

	var reference_checker := TextureRect.new()
	reference_checker.texture = _build_checker_texture()
	reference_checker.stretch_mode = TextureRect.STRETCH_TILE
	reference_checker.size = Vector2(200, 200)
	_reference_viewport.add_child(reference_checker)

	_reference_texture_rect = TextureRect.new()
	_reference_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_reference_viewport.add_child(_reference_texture_rect)

	_frame_info_label = Label.new()
	_frame_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(_frame_info_label)

	_set_zoom(3.0)

func _build_checker_texture() -> ImageTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGB8)
	for y in 16:
		for x in 16:
			var even := ((x / 8) + (y / 8)) % 2 == 0
			img.set_pixel(x, y, Color(0.3, 0.3, 0.3) if even else Color(0.4, 0.4, 0.4))
	return ImageTexture.create_from_image(img)

func _build_inspector_panel(parent: Control) -> void:
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(MIN_SIDE_PANEL_WIDTH, 0)
	panel.size_flags_horizontal = Control.SIZE_FILL
	parent.add_child(panel)
	_inspector_panel = panel

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	panel.add_child(scroll)

	_inspector = InspectorScript.new()
	_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inspector.state_edited.connect(_on_state_edited)
	scroll.add_child(_inspector)

func _build_audit_dialog() -> void:
	_audit_dialog = AcceptDialog.new()
	_audit_dialog.title = "Audit sprites"
	_audit_dialog.min_size = Vector2i(900, 560)
	_audit_dialog.dialog_hide_on_ok = true
	add_child(_audit_dialog)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_audit_dialog.add_child(root)

	var actions := HBoxContainer.new()
	root.add_child(actions)

	var btn_refresh := Button.new()
	btn_refresh.text = "Rafraichir"
	btn_refresh.pressed.connect(_refresh_audit)
	actions.add_child(btn_refresh)

	var btn_export := Button.new()
	btn_export.text = "Exporter"
	btn_export.pressed.connect(_export_audit_report)
	actions.add_child(btn_export)

	_audit_status_label = Label.new()
	_audit_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(_audit_status_label)

	_audit_tree = Tree.new()
	_audit_tree.columns = 4
	_audit_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_audit_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_audit_tree.set_column_title(0, "Severite")
	_audit_tree.set_column_title(1, "Entite")
	_audit_tree.set_column_title(2, "Etat")
	_audit_tree.set_column_title(3, "Message")
	_audit_tree.set_column_titles_visible(true)
	_audit_tree.item_activated.connect(_on_audit_item_activated)
	root.add_child(_audit_tree)

func _load_entities() -> void:
	var file := FileAccess.open(ANIM_CONFIG, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		return
	_entities = parsed
	_entity_list.clear()
	for key in _entities:
		_entity_list.add_item(key)
	if _entity_list.item_count > 0:
		_entity_list.select(0)
		_on_entity_selected(0)

func _on_entity_selected(index: int) -> void:
	_current_entity = _entity_list.get_item_text(index)
	_state_list.clear()
	var entity_cfg: Variant = _entities.get(_current_entity, null)
	if entity_cfg is Dictionary:
		var states: Variant = entity_cfg.get("states", {})
		if states is Dictionary:
			for state_key in states:
				_state_list.add_item(state_key)
	if _state_list.item_count > 0:
		_state_list.select(0)
		_on_state_selected(0)

func _on_state_selected(index: int) -> void:
	var state := _state_list.get_item_text(index)
	_driver.load_entity(_current_entity)
	_driver.play_state(state)
	_update_reference_preview(_current_entity, state)
	_paused = false
	_driver.speed_scale = 1.0
	_btn_pause.text = "II"
	_update_frame_info()

	var entity_cfg: Dictionary = _entities.get(_current_entity, {})
	var states: Dictionary = entity_cfg.get("states", {})
	if states.has(state):
		_inspector.setup(_current_entity, state, states[state], _driver)

func _on_state_edited(entity: String, state: String, _cfg: Dictionary) -> void:
	_dirty = true
	_update_title()
	if entity != _current_entity:
		return
	var entity_cfg: Dictionary = _entities.get(entity, {})
	_driver.load_from_dict(entity_cfg)
	_driver.play_state(state)
	_update_reference_preview(entity, state)
	_driver.speed_scale = 0.0 if _paused else 1.0
	_update_frame_info()

func _update_title() -> void:
	var window := get_window()
	if window == null:
		return
	window.title = WINDOW_TITLE + (" *" if _dirty else "")

func _save() -> void:
	var tmp_path := ANIM_CONFIG + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_warning("echec ouverture fichier temporaire: " + tmp_path)
		return
	file.store_string(JSON.stringify(_entities, "  ", false) + "\n")
	file.close()
	var err := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(tmp_path),
		ProjectSettings.globalize_path(ANIM_CONFIG)
	)
	if err != OK:
		push_warning("echec renommage animations.json: " + str(err))
		return
	_dirty = false
	_update_title()

func _open_audit_dialog() -> void:
	_refresh_audit()
	_audit_dialog.popup_centered()

func _refresh_audit() -> void:
	var manifest := _load_json_dict(MANIFEST_CONFIG)
	if manifest.is_empty():
		_last_audit_results = [{
			"severity": "error",
			"entity": "",
			"state": "",
			"message": "manifest introuvable ou invalide"
		}]
	else:
		_last_audit_results = AuditScript.run_audit(manifest, _entities, "res://assets")
	_sort_audit_results()
	_rebuild_audit_tree()

func _sort_audit_results() -> void:
	_last_audit_results.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var sa := _severity_rank(String(a.get("severity", "")))
		var sb := _severity_rank(String(b.get("severity", "")))
		if sa != sb:
			return sa < sb
		var ea := String(a.get("entity", ""))
		var eb := String(b.get("entity", ""))
		if ea != eb:
			return ea < eb
		var sta := String(a.get("state", ""))
		var stb := String(b.get("state", ""))
		if sta != stb:
			return sta < stb
		return String(a.get("message", "")) < String(b.get("message", ""))
	)

func _severity_rank(severity: String) -> int:
	match severity:
		"error":
			return 0
		"warning":
			return 1
		"info":
			return 2
		_:
			return 3

func _rebuild_audit_tree() -> void:
	_audit_tree.clear()
	var root := _audit_tree.create_item()
	for anomaly in _last_audit_results:
		var item := _audit_tree.create_item(root)
		var severity := String(anomaly.get("severity", ""))
		item.set_text(0, severity)
		item.set_text(1, String(anomaly.get("entity", "")))
		item.set_text(2, String(anomaly.get("state", "")))
		item.set_text(3, String(anomaly.get("message", "")))
		item.set_metadata(0, anomaly)
		match severity:
			"error":
				item.set_custom_color(0, Color(0.95, 0.35, 0.35))
			"warning":
				item.set_custom_color(0, Color(0.95, 0.75, 0.3))
			"info":
				item.set_custom_color(0, Color(0.55, 0.75, 1.0))
	if _last_audit_results.is_empty():
		var ok_item := _audit_tree.create_item(root)
		ok_item.set_text(0, "ok")
		ok_item.set_text(3, "aucune anomalie")
	_audit_status_label.text = "%d anomalie(s)" % _last_audit_results.size()

func _on_audit_item_activated() -> void:
	var item := _audit_tree.get_selected()
	if item == null:
		return
	var meta: Variant = item.get_metadata(0)
	if meta is not Dictionary:
		return
	var entity := String(meta.get("entity", ""))
	var state := String(meta.get("state", ""))
	if entity.is_empty():
		return
	_select_entity_and_state(entity, state)
	if not state.is_empty():
		_audit_dialog.hide()

func _select_entity_and_state(entity: String, state: String) -> void:
	var entity_idx := _find_item_index(_entity_list, entity)
	if entity_idx < 0:
		return
	_entity_list.select(entity_idx)
	_on_entity_selected(entity_idx)
	if state.is_empty():
		return
	var state_idx := _find_item_index(_state_list, state)
	if state_idx < 0:
		return
	_state_list.select(state_idx)
	_on_state_selected(state_idx)

func _find_item_index(list: ItemList, text: String) -> int:
	for i in list.item_count:
		if list.get_item_text(i) == text:
			return i
	return -1

func _export_audit_report() -> void:
	var lines := PackedStringArray()
	lines.append("# Audit sprites")
	lines.append("")
	if _last_audit_results.is_empty():
		lines.append("- [x] aucune anomalie")
	else:
		var severity_counts := {
			"error": 0,
			"warning": 0,
			"info": 0
		}
		var grouped: Dictionary = {}
		for anomaly in _last_audit_results:
			var severity := String(anomaly.get("severity", ""))
			if severity_counts.has(severity):
				severity_counts[severity] += 1
			var entity := String(anomaly.get("entity", ""))
			var state := String(anomaly.get("state", ""))
			if not grouped.has(entity):
				grouped[entity] = {}
			var entity_group: Dictionary = grouped[entity]
			if not entity_group.has(state):
				entity_group[state] = []
			var state_group: Array = entity_group[state]
			state_group.append(anomaly)
			entity_group[state] = state_group
			grouped[entity] = entity_group

		lines.append("- error: %d" % int(severity_counts["error"]))
		lines.append("- warning: %d" % int(severity_counts["warning"]))
		lines.append("- info: %d" % int(severity_counts["info"]))
		lines.append("")

		var entities: PackedStringArray = []
		for entity in grouped.keys():
			entities.append(String(entity))
		entities.sort()
		for entity in entities:
			lines.append("## " + (entity if not entity.is_empty() else "global"))
			lines.append("")
			var entity_group: Dictionary = grouped[entity]
			var states: PackedStringArray = []
			for state in entity_group.keys():
				states.append(String(state))
			states.sort()
			for state in states:
				if not state.is_empty():
					lines.append("### " + state)
					lines.append("")
				var anomalies: Array = entity_group[state]
				for anomaly in anomalies:
					var severity := String(anomaly.get("severity", ""))
					var message := String(anomaly.get("message", ""))
					lines.append("- [ ] %s: %s" % [severity, message])
				lines.append("")
	_write_text_file(AUDIT_REPORT_PATH, "\n".join(lines) + "\n")
	_audit_status_label.text = "%d anomalie(s) - rapport exporte" % _last_audit_results.size()

func _export_entity_specs() -> void:
	var manifest := _load_json_dict(MANIFEST_CONFIG)
	var audit_results := AuditScript.run_audit(manifest, _entities, "res://assets")
	_ensure_specs_dir()
	for entity in _entities.keys():
		var entity_name := String(entity)
		var content := _build_entity_spec(entity_name, manifest, audit_results)
		_write_text_file("%s/%s.md" % [SPECS_DIR, entity_name], content)
	if _audit_status_label != null:
		_audit_status_label.text = "specs exportees"

func _build_entity_spec(entity: String, manifest: Dictionary, audit_results: Array[Dictionary]) -> String:
	var entity_cfg: Dictionary = _entities.get(entity, {})
	var states: Dictionary = entity_cfg.get("states", {})
	var manifest_entity: Dictionary = manifest.get(entity, {})
	var manifest_states: Dictionary = manifest_entity.get("states", {})
	var lines := PackedStringArray()
	lines.append("# " + entity)
	lines.append("")
	lines.append("- default_state: %s" % String(entity_cfg.get("default_state", "")))
	lines.append("- nb_states: %d" % states.size())
	lines.append("")
	lines.append("## Etats")
	lines.append("")
	var state_names: PackedStringArray = []
	for state in states.keys():
		state_names.append(String(state))
	state_names.sort()
	for state in state_names:
		var cfg: Dictionary = states.get(state, {})
		var frames: Array = cfg.get("frames", [])
		var frame_count := frames.size()
		var manifest_state: Dictionary = manifest_states.get(state, {})
		var target_frame_size := _format_frame_size(manifest_state.get("frame_size", []))
		lines.append("### " + state)
		lines.append("")
		lines.append("- target_frame_size: %s" % target_frame_size)
		lines.append("- fps: %.1f" % float(cfg.get("fps", 1.0)))
		lines.append("- loop: %s" % ("true" if bool(cfg.get("loop", true)) else "false"))
		lines.append("- frame_count: %d" % frame_count)
		if cfg.has("sheet"):
			lines.append("- sheet: %s" % String(cfg.get("sheet", "")))
			lines.append("- frame_size: %s" % _format_frame_size(cfg.get("frame_size", [])))
		else:
			lines.append("- sheet: legacy")
			lines.append("- frame_size: n/a")
		lines.append("- offset: %s" % _format_offset(cfg.get("offset", [])))
		lines.append("")
	var entity_anomalies := _filter_entity_anomalies(entity, audit_results)
	lines.append("## Anomalies ouvertes")
	lines.append("")
	if entity_anomalies.is_empty():
		lines.append("- aucune")
	else:
		for anomaly in entity_anomalies:
			var state := String(anomaly.get("state", ""))
			var severity := String(anomaly.get("severity", ""))
			var message := String(anomaly.get("message", ""))
			if state.is_empty():
				lines.append("- %s: %s" % [severity, message])
			else:
				lines.append("- %s / %s: %s" % [state, severity, message])
	lines.append("")
	return "\n".join(lines) + "\n"

func _filter_entity_anomalies(entity: String, audit_results: Array[Dictionary]) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for anomaly in audit_results:
		if String(anomaly.get("entity", "")) == entity:
			filtered.append(anomaly)
	return filtered

func _format_frame_size(value: Variant) -> String:
	if value is Array and value.size() >= 2:
		return "%dx%d" % [int(value[0]), int(value[1])]
	return "n/a"

func _format_offset(value: Variant) -> String:
	if value is Array and value.size() >= 2:
		return "[%.1f, %.1f]" % [float(value[0]), float(value[1])]
	return "[0.0, 0.0]"

func _ensure_specs_dir() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SPECS_DIR))

func _load_json_dict(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _write_text_file(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("echec ecriture: " + path)
		return
	file.store_string(content)
	file.close()

func _set_zoom(z: float) -> void:
	_zoom = z
	_preview_container.stretch_shrink = int(z)
	_reference_preview_container.stretch_shrink = int(z)
	_update_preview_size()

func _update_preview_size() -> void:
	if _preview_container == null or _reference_preview_container == null or _preview_row == null:
		return
	var target_size: float = BASE_PREVIEW_SIZE * _zoom
	var side_width: float = MIN_SIDE_PANEL_WIDTH * 2.0
	if _gallery_panel != null:
		side_width = max(side_width, _gallery_panel.custom_minimum_size.x + MIN_SIDE_PANEL_WIDTH)
	if _inspector_panel != null:
		side_width = max(side_width, MIN_SIDE_PANEL_WIDTH + _inspector_panel.custom_minimum_size.x)
	var available_width: float = size.x - side_width - 48.0
	var total_preview_size: float = clampf(available_width, MIN_PREVIEW_SIZE * 2.0 + 12.0, target_size * 2.0 + 12.0)
	var single_preview_size: float = clampf((total_preview_size - 12.0) / 2.0, MIN_PREVIEW_SIZE, target_size)
	_preview_row.add_theme_constant_override("separation", 12)
	_preview_row.custom_minimum_size = Vector2(single_preview_size * 2.0 + 12.0, single_preview_size)
	_preview_container.custom_minimum_size = Vector2(single_preview_size, single_preview_size)
	_reference_preview_container.custom_minimum_size = Vector2(single_preview_size, single_preview_size)
	_center_preview_driver()
	_center_reference_texture()

func _toggle_pause() -> void:
	_paused = not _paused
	_driver.speed_scale = 0.0 if _paused else 1.0
	_btn_pause.text = ">" if _paused else "II"

func _prev_frame() -> void:
	if _driver.sprite_frames == null or _driver.animation == "":
		return
	var count := _driver.sprite_frames.get_frame_count(_driver.animation)
	_driver.frame = (_driver.frame - 1 + count) % count
	_driver.speed_scale = 0.0
	_paused = true
	_btn_pause.text = ">"
	_update_frame_info()

func _next_frame() -> void:
	if _driver.sprite_frames == null or _driver.animation == "":
		return
	var count := _driver.sprite_frames.get_frame_count(_driver.animation)
	_driver.frame = (_driver.frame + 1) % count
	_driver.speed_scale = 0.0
	_paused = true
	_btn_pause.text = ">"
	_update_frame_info()

func _update_frame_info() -> void:
	if _driver.sprite_frames == null or _driver.animation == "":
		_frame_info_label.text = ""
		return
	var anim := _driver.animation
	var total := _driver.sprite_frames.get_frame_count(anim)
	var cfg := _driver.get_current_state_cfg()
	var fps := float(cfg.get("fps", 1.0))
	var loop := bool(cfg.get("loop", true))
	var size := Vector2i.ZERO
	var fsz: Variant = cfg.get("frame_size", null)
	if fsz is Array and fsz.size() >= 2:
		size = Vector2i(int(fsz[0]), int(fsz[1]))
	else:
		var tex := _driver.sprite_frames.get_frame_texture(anim, _driver.frame)
		if tex != null:
			size = tex.get_size()
	_frame_info_label.text = "%d / %d - %dx%d px - %.1f fps - %s" % [
		_driver.frame + 1, total, size.x, size.y, fps, "loop" if loop else "once"
	]

func _update_reference_preview(entity: String, state: String) -> void:
	var reference_path := _resolve_reference_path(entity, state)
	if reference_path.is_empty():
		_reference_texture_rect.texture = null
		_center_reference_texture()
		return
	_reference_texture_rect.texture = _load_texture(reference_path)
	_center_reference_texture()

func _resolve_reference_path(entity: String, state: String) -> String:
	var entity_cfg: Dictionary = _entities.get(entity, {})
	var states: Dictionary = entity_cfg.get("states", {})
	var state_cfg: Dictionary = states.get(state, {})
	var candidates: PackedStringArray = []
	var state_name := "%s_%s" % [entity, state]
	candidates.append(REFERENCE_ROOT + entity + "/" + state_name + "_ref.png")
	candidates.append(REFERENCE_ROOT + entity + "/" + _normalize_reference_name(state_name) + "_ref.png")
	var sheet_path := String(state_cfg.get("sheet", ""))
	if not sheet_path.is_empty():
		var sheet_name := sheet_path.get_file().get_basename()
		candidates.append(REFERENCE_ROOT + entity + "/" + sheet_name + "_ref.png")
		candidates.append(REFERENCE_ROOT + entity + "/" + _normalize_reference_name(sheet_name) + "_ref.png")
	var frames: Variant = state_cfg.get("frames", [])
	if frames is Array and not frames.is_empty():
		var first_frame := frames[0]
		if first_frame is String:
			var frame_name := String(first_frame).get_file().get_basename()
			candidates.append(REFERENCE_ROOT + entity + "/" + frame_name + "_ref.png")
			candidates.append(REFERENCE_ROOT + entity + "/" + _normalize_reference_name(frame_name) + "_ref.png")
	for candidate in candidates:
		if FileAccess.file_exists(candidate):
			return candidate
	return ""

func _normalize_reference_name(name: String) -> String:
	var normalized := name
	if normalized.ends_with("_sheet"):
		normalized = normalized.trim_suffix("_sheet")
	for suffix in ["_v2", "_v3", "_v4"]:
		if normalized.ends_with(suffix):
			normalized = normalized.trim_suffix(suffix)
	return normalized

func _load_texture(path: String) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

func _center_preview_driver() -> void:
	if _driver == null or _viewport == null:
		return
	_driver.position = Vector2(_viewport.size) * 0.5

func _center_reference_texture() -> void:
	if _reference_texture_rect == null or _reference_viewport == null:
		return
	var texture := _reference_texture_rect.texture
	if texture == null:
		_reference_texture_rect.position = Vector2(_reference_viewport.size) * 0.5
		_reference_texture_rect.size = Vector2.ZERO
		return
	var tex_size := texture.get_size()
	_reference_texture_rect.size = tex_size
	_reference_texture_rect.position = (Vector2(_reference_viewport.size) - tex_size) * 0.5
