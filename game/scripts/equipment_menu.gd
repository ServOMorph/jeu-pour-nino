extends CanvasLayer

const RECIPE_CATALOG := preload("res://scripts/recipe_catalog.gd")

signal closed

const SLOT_ORDER := ["weapon", "armor", "accessory", "tool", "consumable"]
const SLOT_LABELS := {
	"weapon": "ARME",
	"armor": "ARMURE",
	"accessory": "ACCESSOIRE",
	"tool": "OUTIL",
	"consumable": "CONSOMMABLE",
}

var _recipes: Array[Dictionary] = []
var _selected_slot := 0
var _selected_item := 0
var _open := false

var _slot_labels: Array[Label] = []
var _item_labels: Array[Label] = []
var _item_bgs: Array[ColorRect] = []

func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	_recipes = RECIPE_CATALOG.load_recipes()
	RECIPE_CATALOG.bootstrap_starters(_recipes)
	_build_ui()
	visible = false

func open_menu() -> void:
	_open = true
	visible = true
	_selected_slot = 0
	_selected_item = 0
	_refresh()

func close_menu() -> void:
	_open = false
	visible = false
	closed.emit()

func is_open() -> bool:
	return _open

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.74)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := ColorRect.new()
	panel.color = Color(0.09, 0.08, 0.09)
	panel.position = Vector2(380, 184)
	panel.size = Vector2(1160, 712)
	add_child(panel)

	var title := Label.new()
	title.text = "EQUIPEMENT"
	title.position = Vector2(416, 214)
	title.add_theme_font_size_override("font_size", 56)
	title.modulate = Color(0.85, 0.72, 0.42)
	add_child(title)

	var hint := Label.new()
	hint.text = "G/D: slot   H/B: choix   A: equiper   B: fermer"
	hint.position = Vector2(416, 832)
	hint.add_theme_font_size_override("font_size", 28)
	hint.modulate = Color(0.5, 0.5, 0.5)
	add_child(hint)

	for i in SLOT_ORDER.size():
		var slot := SLOT_ORDER[i]
		var lbl := Label.new()
		lbl.position = Vector2(420 + i * 220, 292)
		lbl.size = Vector2(200, 42)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 28)
		lbl.text = String(SLOT_LABELS.get(slot, slot))
		add_child(lbl)
		_slot_labels.append(lbl)

	for i in range(8):
		var bg := ColorRect.new()
		bg.position = Vector2(430, 380 + i * 54)
		bg.size = Vector2(1060, 46)
		add_child(bg)
		_item_bgs.append(bg)

		var lbl := Label.new()
		lbl.position = Vector2(446, 386 + i * 54)
		lbl.size = Vector2(1028, 36)
		lbl.add_theme_font_size_override("font_size", 26)
		add_child(lbl)
		_item_labels.append(lbl)

func _process(_delta: float) -> void:
	if not _open:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		close_menu()
	elif Input.is_action_just_pressed("ui_left"):
		_selected_slot = (_selected_slot - 1 + SLOT_ORDER.size()) % SLOT_ORDER.size()
		_selected_item = 0
		_refresh()
	elif Input.is_action_just_pressed("ui_right"):
		_selected_slot = (_selected_slot + 1) % SLOT_ORDER.size()
		_selected_item = 0
		_refresh()
	elif Input.is_action_just_pressed("ui_up"):
		var options := _current_options()
		if options.is_empty():
			return
		_selected_item = (_selected_item - 1 + options.size()) % options.size()
		_refresh()
	elif Input.is_action_just_pressed("ui_down"):
		var options := _current_options()
		if options.is_empty():
			return
		_selected_item = (_selected_item + 1) % options.size()
		_refresh()
	elif Input.is_action_just_pressed("ui_accept"):
		_apply_selection()

func _current_options() -> Array[Dictionary]:
	var slot := SLOT_ORDER[_selected_slot]
	var options: Array[Dictionary] = [{"id": "", "name": "Aucun"}]
	for recipe in _recipes:
		if String(recipe.get("slot", "")) != slot:
			continue
		var id := String(recipe.get("id", ""))
		if slot == "consumable":
			if RunState.get_consumable_count(id) <= 0:
				continue
		elif not RunState.has_item(id):
			continue
		options.append({
			"id": id,
			"name": String(recipe.get("name", id)),
		})
	return options

func _refresh() -> void:
	for i in SLOT_ORDER.size():
		var slot := SLOT_ORDER[i]
		var equipped := RunState.active_consumable if slot == "consumable" else RunState.get_equipped_item(slot)
		var suffix := " : %s" % equipped if not equipped.is_empty() else ""
		_slot_labels[i].text = "%s%s" % [String(SLOT_LABELS.get(slot, slot)), suffix]
		_slot_labels[i].modulate = Color(1, 1, 1) if i == _selected_slot else Color(0.5, 0.5, 0.5)

	var options := _current_options()
	_selected_item = clampi(_selected_item, 0, max(0, options.size() - 1))
	for i in _item_labels.size():
		var row_visible := i < options.size()
		_item_bgs[i].visible = row_visible
		_item_labels[i].visible = row_visible
		if not row_visible:
			continue
		var option := options[i]
		var id := String(option.get("id", ""))
		var label := String(option.get("name", ""))
		if SLOT_ORDER[_selected_slot] == "consumable" and not id.is_empty():
			label += " x%d" % RunState.get_consumable_count(id)
		_item_labels[i].text = label
		_item_bgs[i].color = Color(0.24, 0.22, 0.18) if i == _selected_item else Color(0.16, 0.15, 0.12)
		_item_labels[i].modulate = Color(1, 1, 1)

func _apply_selection() -> void:
	var options := _current_options()
	if _selected_item >= options.size():
		return
	var slot := SLOT_ORDER[_selected_slot]
	var id := String(options[_selected_item].get("id", ""))
	if slot == "consumable":
		RunState.set_active_consumable(id)
	else:
		RunState.equip_item(slot, id)
	_refresh()
