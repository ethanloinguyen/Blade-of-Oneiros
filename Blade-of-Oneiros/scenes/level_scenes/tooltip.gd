extends Area2D

@export var dialogue_id: String = ""


# =========================
# POT GLOBAL LOGIC
# =========================
static var _pots_initial_count: int = -1
static var _pots_broken: bool = false

# =========================
# FIREPLACE LOGIC (global)
# =========================
static var _fireplace_used: bool = false

# =========================
# BLOCK / GUARDS LOGIC (global)
# =========================
static var _guards_dismissed: bool = false
var _linked_guards: Guards = null

# =========================
# LEVER LOGIC (global)
# =========================
static var _lever_pulled: bool = false

# =========================
# DOOR LOGIC (per-door)
# =========================
var _linked_door: Door = null

# =========================
# COMMON STATE
# =========================
var _player_inside: bool = false


func _ready() -> void:
	# Force-connect signals so editor overrides don't matter
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

	set_process(true)
	set_process_unhandled_input(true)

	# ---------- POTS ----------
	if dialogue_id == "tooltip_pot":
		add_to_group("pot_tooltip")

		if _pots_broken:
			_disable_forever()
			return

		if _pots_initial_count == -1:
			_pots_initial_count = _get_pot_count()

	# ---------- FIREPLACE ----------
	if dialogue_id == "tooltip_fireplace":
		add_to_group("fireplace_tooltip")

		# If some other fireplace tooltip has already been "consumed", kill this one
		if _fireplace_used:
			_disable_forever()
			return

	# ---------- BLOCK / GUARDS ----------
	if dialogue_id == "tooltip_block":
		add_to_group("block_tooltip")

		if _guards_dismissed:
			_disable_forever()
			return

		_linked_guards = _find_guards()

		# If guards already dismissed on load, retire all block-tooltips
		if _linked_guards and _linked_guards.blocker and _linked_guards.blocker.disabled:
			_guards_dismissed = true
			_disable_all_block_tooltips()
			_disable_forever()
			return

	# ---------- LEVER ----------
	if dialogue_id == "tooltip_lever":
		add_to_group("lever_tooltip")

		if _lever_pulled:
			_disable_forever()
			return

	# ---------- DOOR (per-door) ----------
	if dialogue_id == "tooltip_door":
		add_to_group("door_tooltip")

		_linked_door = _find_door()

		# If this door is already open on load, kill this tooltip
		if _linked_door and _is_door_open(_linked_door):
			_disable_forever()
			return


func _process(_delta: float) -> void:
	# ---------- POTS ----------
	if dialogue_id == "tooltip_pot" and not _pots_broken and _pots_initial_count != -1:
		var current := _get_pot_count()
		if current < _pots_initial_count:
			_pots_broken = true
			_disable_all_pot_tooltips()

	# ---------- BLOCK / GUARDS ----------
	if dialogue_id == "tooltip_block" and not _guards_dismissed:
		if _linked_guards == null:
			_linked_guards = _find_guards()

		if _linked_guards and _linked_guards.blocker and _linked_guards.blocker.disabled:
			_guards_dismissed = true
			_disable_all_block_tooltips()

	# ---------- LEVER ----------
	if dialogue_id == "tooltip_lever" and not _lever_pulled:
		if _has_any_lever_been_pulled():
			_lever_pulled = true
			_disable_all_lever_tooltips()

	# ---------- DOOR ----------
	if dialogue_id == "tooltip_door" and _linked_door:
		if _is_door_open(_linked_door):
			_disable_forever()


func _unhandled_input(event: InputEvent) -> void:
	# Only care about fireplace for this
	if dialogue_id != "tooltip_fireplace":
		return
	if not _player_inside:
		return

	# When the player presses interact inside the fireplace tooltip,
	# we consider the "button" discovered/used and retire all fireplace hints.
	if event.is_action_pressed("interact"):
		_fireplace_used = true
		_disable_all_fireplace_tooltips()
		DialogueOrchestrator.skip_all()


# =========================
# POT HELPERS
# =========================
func _get_pot_count() -> int:
	var scene := get_tree().current_scene
	if scene == null:
		return 0
	var vases := scene.find_children("*", "BreakableVase", true, false)
	return vases.size()


func _disable_all_pot_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("pot_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false


# =========================
# FIREPLACE HELPERS
# =========================
func _disable_all_fireplace_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("fireplace_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false


# =========================
# BLOCK / GUARDS HELPERS
# =========================
func _find_guards() -> Guards:
	# 1) Walk up the tree: maybe there's a child "Guards" under a parent
	var node: Node = self
	while node:
		var candidate := node.get_node_or_null("Guards")
		if candidate is Guards:
			return candidate as Guards
		node = node.get_parent()

	# 2) Fallback: search the whole scene
	var scene := get_tree().current_scene
	if scene:
		var found := scene.find_children("*", "Guards", true, false)
		if found.size() > 0:
			return found[0] as Guards

	return null


func _disable_all_block_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("block_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false


# =========================
# LEVER HELPERS
# =========================
func _has_any_lever_been_pulled() -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false

	var levers := scene.find_children("*", "Lever", true, false)
	for n in levers:
		var lever := n as Lever
		if lever == null:
			continue
		if lever.is_on != lever.default_state:
			return true
	return false


func _disable_all_lever_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("lever_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false


# =========================
# DOOR HELPERS
# =========================
func _find_door() -> Door:
	# 1) Walk up parents: maybe tooltip is a child of Door
	var node: Node = self
	while node:
		if node is Door:
			return node as Door
		node = node.get_parent()

	# 2) Fallback: pick the closest Door in the scene
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var doors := scene.find_children("*", "Door", true, false)
	if doors.is_empty():
		return null

	var closest: Door = null
	var best_dist_sq := INF
	for d in doors:
		var door := d as Door
		if door == null:
			continue
		var dist_sq := door.global_position.distance_squared_to(global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			closest = door

	return closest


func _is_door_open(door: Door) -> bool:
	if door == null:
		return false
	var blocker_open := false
	if door.blocker:
		blocker_open = door.blocker.disabled
	return blocker_open or door._is_open


# =========================
# COMMON HELPERS & SIGNAL WRAPPERS
# =========================
func _disable_forever() -> void:
	monitoring = false
	monitorable = false


func _on_enter(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
	_on_body_entered(body)


func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
	_on_body_exited(body)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	# Pots: if pots resolved, no hint
	if dialogue_id == "tooltip_pot" and _pots_broken:
		return

	# Fireplace: if already used, no hint
	if dialogue_id == "tooltip_fireplace" and _fireplace_used:
		return

	# Block: if guards dismissed, no hint
	if dialogue_id == "tooltip_block" and _guards_dismissed:
		return

	# Levers: if any lever already pulled, no hint
	if dialogue_id == "tooltip_lever" and _lever_pulled:
		return

	# Doors: if this specific door is open, no hint
	if dialogue_id == "tooltip_door" and _linked_door and _is_door_open(_linked_door):
		return

	DialogueOrchestrator.start(dialogue_id, null, true)


func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	DialogueOrchestrator.skip_all()
