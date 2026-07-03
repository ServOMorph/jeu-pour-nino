extends VBoxContainer

const ANIM_CONFIG := "res://data/animations.json"
const AnimationDriverEditorScript := preload("res://editeur/animation_driver.gd")

var _entity_list: ItemList
var _state_list: ItemList
var _preview_container: SubViewportContainer
var _viewport: SubViewport
var _driver: AnimationDriverEditorScript
var _entities: Dictionary = {}
var _current_entity := ""
var _paused := false
var _zoom := 3.0

func _ready() -> void:
	_build_ui()
	_load_entities()

func _build_ui() -> void:
	_build_toolbar(self)

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

	var btn_pause := Button.new()
	btn_pause.text = "II / >"
	btn_pause.pressed.connect(_toggle_pause)
	bar.add_child(btn_pause)

	var btn_next := Button.new()
	btn_next.text = ">|"
	btn_next.pressed.connect(_next_frame)
	bar.add_child(btn_next)

func _build_gallery_panel(parent: Control) -> void:
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(180, 0)
	parent.add_child(panel)

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

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(center)

	_preview_container = SubViewportContainer.new()
	_preview_container.stretch = true
	_preview_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	center.add_child(_preview_container)

	_viewport = SubViewport.new()
	_viewport.size = Vector2i(200, 200)
	_viewport.transparent_bg = true
	_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_preview_container.add_child(_viewport)

	_driver = AnimationDriverEditorScript.new()
	_driver.position = Vector2(100, 100)
	_viewport.add_child(_driver)

	_set_zoom(3.0)

func _build_inspector_panel(parent: Control) -> void:
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(160, 0)
	parent.add_child(panel)

	var lbl := Label.new()
	lbl.text = "Inspecteur\n(Phase 3)"
	panel.add_child(lbl)

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
	_paused = false
	_driver.speed_scale = 1.0

func _set_zoom(z: float) -> void:
	_zoom = z
	_preview_container.custom_minimum_size = Vector2(200.0 * z, 200.0 * z)

func _toggle_pause() -> void:
	_paused = not _paused
	_driver.speed_scale = 0.0 if _paused else 1.0

func _prev_frame() -> void:
	if _driver.sprite_frames == null or _driver.animation == "":
		return
	var count := _driver.sprite_frames.get_frame_count(_driver.animation)
	_driver.frame = (_driver.frame - 1 + count) % count
	_driver.speed_scale = 0.0
	_paused = true

func _next_frame() -> void:
	if _driver.sprite_frames == null or _driver.animation == "":
		return
	var count := _driver.sprite_frames.get_frame_count(_driver.animation)
	_driver.frame = (_driver.frame + 1) % count
	_driver.speed_scale = 0.0
	_paused = true
