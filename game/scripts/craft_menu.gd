extends CanvasLayer

const RECIPE_FILE := "res://data/recipes.json"
const LEGACY_RESOURCE_MATERIAL := "cuivre"
const PX := 560.0
const PY := 308.0
const PW := 800.0
const ROW_H := 88.0

var PH := 460.0

var _recipes: Array = []
var _visible_recipes: Array = []
var _selected := 0
var _row_bgs: Array[ColorRect] = []
var _row_labels: Array[Label] = []

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_recipes()
	_build_ui()
	visible = false

func _load_recipes() -> void:
	var f := FileAccess.open(RECIPE_FILE, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Array:
		_recipes = parsed
	PH = 104.0 + _recipes.size() * ROW_H + 80.0

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.size = Vector2(1920, 1080)
	add_child(dim)

	var panel := ColorRect.new()
	panel.color = Color(0.12, 0.10, 0.08)
	panel.position = Vector2(PX, PY)
	panel.size = Vector2(PW, PH)
	add_child(panel)

	var title := Label.new()
	title.text = "ETABLI"
	title.position = Vector2(PX + 32, PY + 24)
	title.add_theme_font_size_override("font_size", 40)
	title.modulate = Color(0.9, 0.75, 0.4)
	add_child(title)

	var sep := ColorRect.new()
	sep.color = Color(0.4, 0.3, 0.15)
	sep.position = Vector2(PX + 16, PY + 88)
	sep.size = Vector2(PW - 32, 4)
	add_child(sep)

	for i in _recipes.size():
		_build_row(i)

	var hint := Label.new()
	hint.text = "A: craft   B: fermer"
	hint.position = Vector2(PX + 16, PY + PH - 56)
	hint.add_theme_font_size_override("font_size", 28)
	hint.modulate = Color(0.45, 0.45, 0.45)
	add_child(hint)

func _build_row(i: int) -> void:
	var recipe: Dictionary = _recipes[i]
	var y := PY + 104.0 + i * ROW_H

	var bg := ColorRect.new()
	bg.position = Vector2(PX + 16, y)
	bg.size = Vector2(PW - 32, ROW_H - 16)
	bg.color = Color(0.20, 0.18, 0.15)
	add_child(bg)

	var lbl := Label.new()
	lbl.text = "%s — %s" % [recipe["name"], _format_costs(_get_recipe_costs(recipe))]
	lbl.position = Vector2(PX + 32, y + 8)
	lbl.add_theme_font_size_override("font_size", 36)
	add_child(lbl)

	_row_bgs.append(bg)
	_row_labels.append(lbl)

func open() -> void:
	_sync_visible_recipes()
	_selected = 0
	_refresh()
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

func _refresh() -> void:
	_sync_visible_recipes()
	for i in _recipes.size():
		var row_visible := i < _visible_recipes.size()
		_row_bgs[i].visible = row_visible
		_row_labels[i].visible = row_visible
		if not row_visible:
			continue
		var recipe: Dictionary = _visible_recipes[i]
		var costs := _get_recipe_costs(recipe)
		var cost_text := _format_costs(costs)
		var id: String = recipe["id"]
		var is_consumable: bool = recipe.get("consumable", false)
		var done := false
		if not is_consumable:
			done = RunState.has_item(id)
		var affordable := _can_afford(costs)

		_row_bgs[i].color = Color(0.30, 0.26, 0.20) if i == _selected else Color(0.20, 0.18, 0.15)

		if done:
			_row_labels[i].text = "%s [PRET]" % recipe["name"]
			_row_labels[i].modulate = Color(0.45, 0.70, 0.45)
		elif affordable:
			_row_labels[i].text = "%s — %s" % [recipe["name"], cost_text]
			_row_labels[i].modulate = Color(1.0, 0.95, 0.8)
		else:
			_row_labels[i].text = "%s — %s" % [recipe["name"], cost_text]
			_row_labels[i].modulate = Color(0.45, 0.45, 0.45)

func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		close()
	elif Input.is_action_just_pressed("ui_up"):
		if _visible_recipes.is_empty():
			return
		_selected = (_selected - 1 + _visible_recipes.size()) % _visible_recipes.size()
		_refresh()
	elif Input.is_action_just_pressed("ui_down"):
		if _visible_recipes.is_empty():
			return
		_selected = (_selected + 1) % _visible_recipes.size()
		_refresh()
	elif Input.is_action_just_pressed("ui_accept"):
		_try_craft(_selected)

func _try_craft(i: int) -> void:
	if i >= _visible_recipes.size():
		return
	var recipe: Dictionary = _visible_recipes[i]
	var id: String = recipe["id"]
	var is_consumable: bool = recipe.get("consumable", false)
	if not is_consumable:
		if RunState.has_item(id):
			return
	if RunState.spend_materials(_get_recipe_costs(recipe)):
		if is_consumable:
			RunState.add_consumable(id)
		else:
			RunState.add_item(id)
		_refresh()
	else:
		AudioManager.play("cant_craft")
		_flash_fail(i)

func _flash_fail(i: int) -> void:
	var lbl := _row_labels[i]
	var t := lbl.create_tween()
	t.tween_property(lbl, "modulate", Color(1.0, 0.2, 0.2), 0.05)
	t.tween_property(lbl, "modulate", Color(0.45, 0.45, 0.45), 0.20)

func _sync_visible_recipes() -> void:
	_visible_recipes.clear()
	for recipe in _recipes:
		if _is_recipe_obsolete(recipe):
			continue
		_visible_recipes.append(recipe)
	if _visible_recipes.is_empty():
		_selected = 0
	else:
		_selected = clampi(_selected, 0, _visible_recipes.size() - 1)

func _is_recipe_obsolete(recipe: Dictionary) -> bool:
	var id: String = recipe["id"]
	if id == "epee_bois" and (RunState.has_item("epee_cuivre") or RunState.has_item("epee_fer")):
		return true
	if id == "epee_cuivre" and RunState.has_item("epee_fer"):
		return true
	return false

func _get_recipe_costs(recipe: Dictionary) -> Dictionary:
	var raw_costs: Variant = recipe.get("materials", {})
	if raw_costs is Dictionary and not raw_costs.is_empty():
		return raw_costs
	if "cost" in recipe:
		return {LEGACY_RESOURCE_MATERIAL: int(recipe["cost"])}
	return {}

func _can_afford(costs: Dictionary) -> bool:
	for raw_id in costs.keys():
		var id := String(raw_id)
		var qty := int(costs[raw_id])
		if RunState.get_material(id) < qty:
			return false
	return true

func _format_costs(costs: Dictionary) -> String:
	var parts: Array[String] = []
	for raw_id in costs.keys():
		var id := String(raw_id)
		parts.append("%s x%d" % [RunState.get_material_name(id), int(costs[raw_id])])
	parts.sort()
	return ", ".join(parts)
