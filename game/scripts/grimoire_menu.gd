extends CanvasLayer

const RECIPE_CATALOG := preload("res://scripts/recipe_catalog.gd")

signal closed

const PX := 360.0
const PY := 160.0
const PW := 1200.0
const ROW_H := 60.0
const VISIBLE_ROWS := 12
const PH := 96.0 + VISIBLE_ROWS * ROW_H + 80.0

var _recipes: Array[Dictionary] = []
var _visible_recipes: Array[Dictionary] = []
var _row_bgs: Array[ColorRect] = []
var _row_labels: Array[Label] = []
var _selected := 0
var _window_start := 0
var _open := false
var _skill_label: Label
var _position_label: Label

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_recipes = RECIPE_CATALOG.load_recipes()
	RECIPE_CATALOG.bootstrap_starters(_recipes)
	_build_ui()
	visible = false
	MetaState.skill_points_changed.connect(_on_meta_changed)
	MetaState.grimoire_changed.connect(_on_meta_changed)

func is_open() -> bool:
	return _open

func open_menu() -> void:
	_sync_visible_recipes()
	_selected = clampi(_selected, 0, max(0, _visible_recipes.size() - 1))
	_open = true
	visible = true
	_refresh()

func close_menu() -> void:
	_open = false
	visible = false
	closed.emit()

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := ColorRect.new()
	panel.color = Color(0.08, 0.07, 0.06)
	panel.position = Vector2(PX, PY)
	panel.size = Vector2(PW, PH)
	add_child(panel)

	var title := Label.new()
	title.text = "GRIMOIRE"
	title.position = Vector2(PX + 28, PY + 20)
	title.add_theme_font_size_override("font_size", 56)
	title.modulate = Color(0.9, 0.78, 0.45)
	add_child(title)

	_skill_label = Label.new()
	_skill_label.position = Vector2(PX + 700, PY + 28)
	_skill_label.size = Vector2(240, 48)
	_skill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_skill_label.add_theme_font_size_override("font_size", 34)
	add_child(_skill_label)

	_position_label = Label.new()
	_position_label.position = Vector2(PX + 950, PY + 34)
	_position_label.size = Vector2(210, 40)
	_position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_position_label.add_theme_font_size_override("font_size", 26)
	_position_label.modulate = Color(0.55, 0.55, 0.55)
	add_child(_position_label)

	var hint := Label.new()
	hint.text = "A: maitriser   B: fermer   Haut/Bas: naviguer"
	hint.position = Vector2(PX + 24, PY + PH - 56)
	hint.add_theme_font_size_override("font_size", 26)
	hint.modulate = Color(0.5, 0.5, 0.5)
	add_child(hint)

	for row in VISIBLE_ROWS:
		var bg := ColorRect.new()
		bg.position = Vector2(PX + 20, PY + 96 + row * ROW_H)
		bg.size = Vector2(PW - 40, ROW_H - 8)
		add_child(bg)
		_row_bgs.append(bg)

		var lbl := Label.new()
		lbl.position = Vector2(PX + 36, PY + 104 + row * ROW_H)
		lbl.size = Vector2(PW - 72, ROW_H - 16)
		lbl.add_theme_font_size_override("font_size", 26)
		add_child(lbl)
		_row_labels.append(lbl)

func _process(_delta: float) -> void:
	if not _open:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		close_menu()
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
		_try_master_selected()

func _sync_visible_recipes() -> void:
	_visible_recipes.clear()
	for recipe in _recipes:
		var id := String(recipe.get("id", ""))
		if MetaState.is_discovered(id) or bool(recipe.get("starter", false)):
			_visible_recipes.append(recipe)

func _refresh() -> void:
	if _recipes.is_empty():
		return
	_sync_visible_recipes()
	var total := _visible_recipes.size()
	_selected = clampi(_selected, 0, max(0, total - 1))
	_skill_label.text = "PC %d" % MetaState.skill_points
	_position_label.text = "%d/%d" % [_selected + 1, total] if total > 0 else ""

	_window_start = 0
	if total > VISIBLE_ROWS:
		_window_start = clampi(_selected - VISIBLE_ROWS / 2, 0, total - VISIBLE_ROWS)
		_window_start = mini(_window_start, _selected)
		_window_start = maxi(_window_start, _selected - VISIBLE_ROWS + 1)

	for row in VISIBLE_ROWS:
		var idx := _window_start + row
		var row_visible := idx < total
		_row_bgs[row].visible = row_visible
		_row_labels[row].visible = row_visible
		if not row_visible:
			continue
		var recipe := _visible_recipes[idx]
		var id := String(recipe.get("id", ""))
		var mastered := MetaState.is_mastered(id)
		var skill_cost := int(recipe.get("skill_cost", 0))
		var status := "[MAITRISEE]" if mastered else "[%d PC]" % skill_cost
		var discovery := String(recipe.get("discovery", ""))
		_row_labels[row].text = "%s - %s - %s" % [String(recipe.get("name", id)), status, discovery]
		_row_bgs[row].color = Color(0.24, 0.22, 0.18) if idx == _selected else Color(0.16, 0.15, 0.12)
		if mastered:
			_row_labels[row].modulate = Color(0.45, 0.82, 0.45)
		elif MetaState.skill_points >= skill_cost:
			_row_labels[row].modulate = Color(0.95, 0.92, 0.8)
		else:
			_row_labels[row].modulate = Color(0.45, 0.45, 0.45)

func _try_master_selected() -> void:
	if _selected >= _visible_recipes.size():
		return
	var recipe := _visible_recipes[_selected]
	var id := String(recipe.get("id", ""))
	if MetaState.is_mastered(id):
		return
	if MetaState.master_recipe(id, int(recipe.get("skill_cost", 0))):
		_refresh()
	else:
		_flash_fail(_selected - _window_start)

func _flash_fail(row: int) -> void:
	if row < 0 or row >= _row_labels.size():
		return
	var lbl := _row_labels[row]
	var tween := lbl.create_tween()
	tween.tween_property(lbl, "modulate", Color(1.0, 0.2, 0.2), 0.05)
	tween.tween_property(lbl, "modulate", Color(0.45, 0.45, 0.45), 0.18)

func _on_meta_changed(_value: Variant = null) -> void:
	if _open:
		_refresh()
