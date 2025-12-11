extends Area2D

@export var dialogue_id: String = ""

# =========================
# GLOBAL STATE (Cached)
# =========================
static var _pots_initial_count: int = -1
static var _pots_broken: bool = false
static var _all_vases_cached: Array = []

static var _fireplace_used: bool = false

static var _guards_dismissed: bool = false
var _linked_guards: Guards = null

static var _lever_pulled: bool = false
static var _all_levers_cached: Array = []

var _linked_door: Door = null
var _player_inside: bool = false


func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

	set_process(true)
	set_process_unhandled_input(true)

	var scene := get_tree().current_scene

	# ---------- CACHE ALL VASES ON FIRST LOAD ----------
	if _pots_initial_count == -1:
		_all_vases_cached = get_tree().get_nodes_in_group("vase")
		_pots_initial_count = _all_vases_cached.size()

	# ---------- CACHE ALL LEVERS ON FIRST LOAD ----------
	if _all_levers_cached.is_empty():
		_all_levers_cached = get_tree().get_nodes_in_group("Lever")

	# ---------- POTS ----------
	if dialogue_id == "tooltip_pot":
		add_to_group("pot_tooltip")

		if _pots_broken:
			_disable_and_stop()
			return

	# ---------- FIREPLACE ----------
	if dialogue_id == "tooltip_fireplace":
		add_to_group("fireplace_tooltip")
		if _fireplace_used:
			_disable_and_stop()
			return

	# ---------- BLOCK / GUARDS ----------
	if dialogue_id == "tooltip_block":
		add_to_group("block_tooltip")

		# Cache guards once
		_linked_guards = _find_guards_once()

		if _guards_dismissed:
			_disable_and_stop()
			return

		if _linked_guards and _linked_guards.blocker and _linked_guards.blocker.disabled:
			_guards_dismissed = true
			_disable_all_block_tooltips()
			_disable_and_stop()
			return

	# ---------- LEVER ----------
	if dialogue_id == "tooltip_lever":
		add_to_group("lever_tooltip")
		if _lever_pulled:
			_disable_and_stop()
			return

	# ---------- DOOR ----------
	if dialogue_id == "tooltip_door":
		add_to_group("door_tooltip")

		# Cache once
		_linked_door = _find_door_once()

		if _linked_door and _is_door_open(_linked_door):
			_disable_and_stop()
			return


func _process(_delta: float) -> void:
	# ---------- POT CHANGES ----------
	if dialogue_id == "tooltip_pot" and not _pots_broken:
		var current := _all_vases_cached.size()
		if current < _pots_initial_count:
			_pots_broken = true
			_disable_all_pot_tooltips()
			_disable_and_stop()

	# ---------- BLOCK / GUARDS ----------
	if dialogue_id == "tooltip_block" and not _guards_dismissed:
		if _linked_guards and _linked_guards.blocker and _linked_guards.blocker.disabled:
			_guards_dismissed = true
			_disable_all_block_tooltips()
			_disable_and_stop()

	# ---------- LEVER ----------
	if dialogue_id == "tooltip_lever" and not _lever_pulled:
		if _has_any_lever_been_pulled_cached():
			_lever_pulled = true
			_disable_all_lever_tooltips()
			_disable_and_stop()

	# ---------- DOOR ----------
	if dialogue_id == "tooltip_door" and _linked_door:
		if _is_door_open(_linked_door):
			_disable_and_stop()


func _unhandled_input(event: InputEvent) -> void:
	if dialogue_id != "tooltip_fireplace" or not _player_inside:
		return

	if event.is_action_pressed("interact"):
		_fireplace_used = true
		_disable_all_fireplace_tooltips()
		DialogueOrchestrator.skip_all()


# =========================
# OPTIMIZED HELPERS
# =========================

func _find_guards_once() -> Guards:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var list := get_tree().get_nodes_in_group("guards")
	if list.is_empty():
		return null
	else: 
		return list[0]


func _find_door_once() -> Door:
	var list := get_tree().get_nodes_in_group("door")
	if list.is_empty():
		return null

	# pick closest
	var closest := list[0]
	var best_dist := INF

	for d in list:
		var door := d as Door
		if door == null:
			continue

		var dist: float = door.global_position.distance_squared_to(global_position)

		if dist < best_dist:
			best_dist = dist
			closest = door

	return closest


func _has_any_lever_been_pulled_cached() -> bool:
	for lever in _all_levers_cached:
		if lever.is_on != lever.default_state:
			return true
	return false


func _is_door_open(door: Door) -> bool:
	var blocker_open := door.blocker and door.blocker.disabled
	return blocker_open or door._is_open


func _on_enter(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
	_on_body_entered(body)


func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
	_on_body_exited(body)


func _disable_and_stop() -> void:
	monitoring = false
	monitorable = false
	set_process(false)
	set_process_unhandled_input(false)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	if dialogue_id == "tooltip_pot" and _pots_broken:
		return
	if dialogue_id == "tooltip_fireplace" and _fireplace_used:
		return
	if dialogue_id == "tooltip_block" and _guards_dismissed:
		return
	if dialogue_id == "tooltip_lever" and _lever_pulled:
		return
	if dialogue_id == "tooltip_door" and _linked_door and _is_door_open(_linked_door):
		return

	DialogueOrchestrator.start(dialogue_id, null, true)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		DialogueOrchestrator.skip_all()


# =========================
# BULK DISABLE HELPERS
# =========================

func _disable_all_pot_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("pot_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false
			# also disable per-node processing (if present)
			if "set_process" in node:
				node.set_process(false)
				node.set_process_unhandled_input(false)

func _disable_all_fireplace_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("fireplace_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false
			if "set_process" in node:
				node.set_process(false)
				node.set_process_unhandled_input(false)

func _disable_all_block_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("block_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false
			if "set_process" in node:
				node.set_process(false)
				node.set_process_unhandled_input(false)

func _disable_all_lever_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("lever_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false
			if "set_process" in node:
				node.set_process(false)
				node.set_process_unhandled_input(false)

func _disable_all_door_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("door_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false
			if "set_process" in node:
				node.set_process(false)
				node.set_process_unhandled_input(false)
