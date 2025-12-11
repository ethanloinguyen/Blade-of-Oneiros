extends Area2D

@export var dialogue_id: String = ""

# ================================================== Tooltip.gd
# Demuxer/handler for all tooltip area2Ds

# =========================Pot Logic
static var _pots_initial_count: int = -1
static var _pots_broken: bool = false

# ========================= Fireplace Logic 

static var _fireplace_used: bool = false

# ========================= Guards Logic 
static var _guards_dismissed: bool = false
var _linked_guards: Guards = null

# ========================= Lever Logic 
static var _lever_pulled: bool = false

# ========================= Door Logic 
var _linked_door: Door = null

# ========================= Common State
var _player_inside: bool = false


func _ready() -> void:
	# Force-connect signals 
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

	set_process(true)
	set_process_unhandled_input(true)

	# ------------------------------ Pots 
	if dialogue_id == "tooltip_pot":
		add_to_group("pot_tooltip")

		if _pots_broken:
			_disable_forever()
			return

		if _pots_initial_count == -1:
			_pots_initial_count = _get_pot_count()

	# ------------------------------ Fireplace
	if dialogue_id == "tooltip_fireplace":
		add_to_group("fireplace_tooltip")


		if _fireplace_used:
			_disable_forever()
			return

	# ------------------------------ Guards
	if dialogue_id == "tooltip_block":
		add_to_group("block_tooltip")

		if _guards_dismissed:
			_disable_forever()
			return

		_linked_guards = _find_guards()

		# If guards dismissed, retire block-tooltips
		if _linked_guards and _linked_guards.blocker and _linked_guards.blocker.disabled:
			_guards_dismissed = true
			_disable_all_block_tooltips()
			_disable_forever()
			return

	# ------------------------------ Lever
	if dialogue_id == "tooltip_lever":
		add_to_group("lever_tooltip")

		if _lever_pulled:
			_disable_forever()
			return

	# ------------------------------ Door
	if dialogue_id == "tooltip_door":
		add_to_group("door_tooltip")

		_linked_door = _find_door()

		# If door already open, kill tooltip
		if _linked_door and _is_door_open(_linked_door):
			_disable_forever()
			return


func _process(_delta: float) -> void:
	# ------------------------------ Pots
	if dialogue_id == "tooltip_pot" and not _pots_broken and _pots_initial_count != -1:
		var current := _get_pot_count()
		if current < _pots_initial_count:
			_pots_broken = true
			_disable_all_pot_tooltips()

	# ------------------------------ Guards
	if dialogue_id == "tooltip_block" and not _guards_dismissed:
		if _linked_guards == null:
			_linked_guards = _find_guards()

		if _linked_guards and _linked_guards.blocker and _linked_guards.blocker.disabled:
			_guards_dismissed = true
			_disable_all_block_tooltips()

	# ------------------------------ Lever
	if dialogue_id == "tooltip_lever" and not _lever_pulled:
		if _has_any_lever_been_pulled():
			_lever_pulled = true
			_disable_all_lever_tooltips()

	# ------------------------------ Door
	if dialogue_id == "tooltip_door" and _linked_door:
		if _is_door_open(_linked_door):
			_disable_forever()


func _unhandled_input(event: InputEvent) -> void:
	if dialogue_id != "tooltip_fireplace":
		return
	if not _player_inside:
		return

	# When the player interacts w/ fireplace, retire all fireplace hints.
	if event.is_action_pressed("interact"):
		_fireplace_used = true
		_disable_all_fireplace_tooltips()
		DialogueOrchestrator.skip_all()


# ========================= Pot helpers

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


# ========================= Fireplace helpers
func _disable_all_fireplace_tooltips() -> void:
	for node in get_tree().get_nodes_in_group("fireplace_tooltip"):
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false


# ========================= Guards helpers
func _find_guards() -> Guards:
	var node: Node = self
	while node:
		var candidate := node.get_node_or_null("Guards")
		if candidate is Guards:
			return candidate as Guards
		node = node.get_parent()

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


# ========================= Lever helpers
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


# ========================= Door helpers
func _find_door() -> Door:
	var node: Node = self
	while node:
		if node is Door:
			return node as Door
		node = node.get_parent()

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


# # ========================= Common helpers/Signals
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

	# if pots resolved, no hint
	if dialogue_id == "tooltip_pot" and _pots_broken:
		return

	# if already used, no hint
	if dialogue_id == "tooltip_fireplace" and _fireplace_used:
		return

	# if guards dismissed, no hint
	if dialogue_id == "tooltip_block" and _guards_dismissed:
		return

	# if any lever already pulled, no hint
	if dialogue_id == "tooltip_lever" and _lever_pulled:
		return

	# if this specific door is open, no hint
	if dialogue_id == "tooltip_door" and _linked_door and _is_door_open(_linked_door):
		return

	DialogueOrchestrator.start(dialogue_id, null, true)


func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	DialogueOrchestrator.skip_all()
