extends CanvasLayer

const RECIPE_CATALOG := preload("res://scripts/recipe_catalog.gd")

const PX := 560.0
const PY := 160.0
const PW := 800.0
const ROW_H := 68.0
const VISIBLE_ROWS := 10

var PH := 104.0 + VISIBLE_ROWS * ROW_H + 80.0

var _recipes: Array[Dictionary] = []
var _visible_recipes: Array[Dictionary] = []
var _selected := 0
var _window_start := 0
var _row_bgs: Array[ColorRect] = []
var _row_labels: Array[Label] = []
var _workbench_tier := 1
var _position_label: Label

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_recipes()
	_build_ui()
	visible = false

func _load_recipes() -> void:
	_recipes = RECIPE_CATALOG.load_recipes()
	RECIPE_CATALOG.bootstrap_starters(_recipes)

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

	_position_label = Label.new()
	_position_label.position = Vector2(PX + PW - 240, PY + 32)
	_position_label.size = Vector2(200, 40)
	_position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_position_label.add_theme_font_size_override("font_size", 26)
	_position_label.modulate = Color(0.55, 0.55, 0.55)
	add_child(_position_label)

	var sep := ColorRect.new()
	sep.color = Color(0.4, 0.3, 0.15)
	sep.position = Vector2(PX + 16, PY + 88)
	sep.size = Vector2(PW - 32, 4)
	add_child(sep)

	for row in VISIBLE_ROWS:
		_build_row(row)

	var hint := Label.new()
	hint.text = "A: craft   B: fermer   Haut/Bas: naviguer"
	hint.position = Vector2(PX + 16, PY + PH - 56)
	hint.add_theme_font_size_override("font_size", 26)
	hint.modulate = Color(0.45, 0.45, 0.45)
	add_child(hint)

func _build_row(row: int) -> void:
	var y := PY + 104.0 + row * ROW_H

	var bg := ColorRect.new()
	bg.position = Vector2(PX + 16, y)
	bg.size = Vector2(PW - 32, ROW_H - 12)
	bg.color = Color(0.20, 0.18, 0.15)
	add_child(bg)

	var lbl := Label.new()
	lbl.position = Vector2(PX + 32, y + 6)
	lbl.add_theme_font_size_override("font_size", 28)
	add_child(lbl)

	_row_bgs.append(bg)
	_row_labels.append(lbl)

func open(workbench_tier: int = 1) -> void:
	_workbench_tier = max(1, workbench_tier)
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
	var total := _visible_recipes.size()
	_window_start = 0
	if total > VISIBLE_ROWS:
		_window_start = clampi(_selected - VISIBLE_ROWS / 2, 0, total - VISIBLE_ROWS)
		_window_start = mini(_window_start, _selected)
		_window_start = maxi(_window_start, _selected - VISIBLE_ROWS + 1)
	_position_label.text = "%d/%d" % [_selected + 1, total] if total > 0 else ""

	for row in VISIBLE_ROWS:
		var idx := _window_start + row
		var row_visible := idx < total
		_row_bgs[row].visible = row_visible
		_row_labels[row].visible = row_visible
		if not row_visible:
			continue
		var recipe: Dictionary = _visible_recipes[idx]
		var costs := _get_recipe_costs(recipe)
		var cost_text := _format_costs(costs)
		var id := String(recipe.get("id", ""))
		var is_consumable := String(recipe.get("slot", "")) == "consumable"
		var done := false
		if not is_consumable:
			done = RunState.has_item(id)
		var affordable := _can_afford(costs)

		_row_bgs[row].color = Color(0.30, 0.26, 0.20) if idx == _selected else Color(0.20, 0.18, 0.15)

		if done:
			_row_labels[row].text = "%s [PRET]" % recipe["name"]
			_row_labels[row].modulate = Color(0.45, 0.70, 0.45)
		elif affordable:
			_row_labels[row].text = "%s — %s" % [recipe["name"], cost_text]
			_row_labels[row].modulate = Color(1.0, 0.95, 0.8)
		else:
			_row_labels[row].text = "%s — %s" % [recipe["name"], cost_text]
			_row_labels[row].modulate = Color(0.45, 0.45, 0.45)

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
	var id := String(recipe.get("id", ""))
	var is_consumable := String(recipe.get("slot", "")) == "consumable"
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
		_flash_fail(i - _window_start)

func _flash_fail(row: int) -> void:
	if row < 0 or row >= _row_labels.size():
		return
	var lbl := _row_labels[row]
	var t := lbl.create_tween()
	t.tween_property(lbl, "modulate", Color(1.0, 0.2, 0.2), 0.05)
	t.tween_property(lbl, "modulate", Color(0.45, 0.45, 0.45), 0.20)

func _sync_visible_recipes() -> void:
	_visible_recipes.clear()
	for recipe in _recipes:
		var id := String(recipe.get("id", ""))
		if not MetaState.is_mastered(id):
			continue
		if int(recipe.get("workbench_tier", 1)) > _workbench_tier:
			continue
		if _is_recipe_obsolete(recipe):
			continue
		_visible_recipes.append(recipe)
	if _visible_recipes.is_empty():
		_selected = 0
	else:
		_selected = clampi(_selected, 0, _visible_recipes.size() - 1)

func _is_recipe_obsolete(recipe: Dictionary) -> bool:
	var id := String(recipe.get("id", ""))
	if id == "epee_bois" and (RunState.has_item("epee_cuivre") or RunState.has_item("epee_fer")):
		return true
	if id == "epee_cuivre" and RunState.has_item("epee_fer"):
		return true
	return false

func _get_recipe_costs(recipe: Dictionary) -> Dictionary:
	var raw_costs: Variant = recipe.get("materials", {})
	if raw_costs is Dictionary and not raw_costs.is_empty():
		return raw_costs
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
