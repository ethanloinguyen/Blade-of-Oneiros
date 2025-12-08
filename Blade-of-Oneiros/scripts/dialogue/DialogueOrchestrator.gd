extends Node

enum State {
	IDLE,
	RUNNING_SCRIPT
}

var _state:= State.IDLE
var _current_lines: Array = []
var _current_script_id: String = ""
var _dialog_ui: Node = null
var _left_character_id: String = ""
var _right_character_id: String = ""
var _steps: Array = []
var _step_index: int = 0


# Map character IDs (like "swordsman", "shadowman") to actual nodes
var _character_registry: Dictionary = {}

# Optional: if other systems want to listen for cutscene actions
signal action_enqueued(character_id: String, action_type: String, payload: Dictionary)

# Map dialogue IDs to script resource paths.
# You can fill this in code or via an exported Dictionary if you prefer.
var _script_paths: Dictionary = {
	"npc_intro_1": "res://scripts/dialogue/scripts/dialogue_script_intro.gd",
	"npc_intro_2": "res://scripts/dialogue/scripts/dialogue_script_intro_2.gd",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Try to find any node named "DialogUI" anywhere in the tree.
	_dialog_ui = get_tree().root.find_child("DialogUI", true, false)

	if _dialog_ui == null:
		push_warning("DialogueOrchestrator: Could not find any node named 'DialogUI' in the scene tree.")
	else:
		print("DEBUG: DialogueOrchestrator found DialogUI at: ", _dialog_ui.get_path())

# --------------------------------------------------------------
# Public API: Player / triggers use these
# --------------------------------------------------------------

func is_dialogue_active() -> bool:
	if _dialog_ui == null:
		return false

	if _dialog_ui.has_method("is_open") and _dialog_ui.is_open():
		return true

	# Fallback to internal state (in case you run dialogue without UI for some reason)
	return _state != State.IDLE



func start(dialogue_id: String, dialog_ui: Node = null) -> void:
	print("DEBUG: DialogueOrchestrator.start called with id: ", dialogue_id)

	if _state != State.IDLE:
		print("DEBUG: state is not IDLE (", _state, "), aborting")
		return

	if !_script_paths.has(dialogue_id):
		push_warning("DialogueOrchestrator: No script found for id '%s'" % dialogue_id)
		print("DEBUG: _script_paths DOES NOT have key: ", dialogue_id)
		return
	print("DEBUG: _script_paths HAS key: ", dialogue_id)

	# Use the dialog_ui if one was passed in, otherwise auto-resolve
	if dialog_ui != null:
		set_dialog_ui(dialog_ui)
	elif _dialog_ui == null:
		var found := get_tree().root.find_child("DialogUI", true, false)
		if found == null:
			push_warning("DialogueOrchestrator: DialogUI not found; cannot start dialogue.")
			print("DEBUG: _dialog_ui is STILL NULL after re-search")
			return
		set_dialog_ui(found)

	print("DEBUG: _dialog_ui is valid: ", _dialog_ui)

	_current_script_id = dialogue_id
	_current_lines.clear()
	# also clear steps if you’re using the step queue
	_steps.clear()
	_step_index = 0
	_state = State.RUNNING_SCRIPT

	var path: String = _script_paths[dialogue_id]
	print("DEBUG: loading script at path: ", path)
	var script_res: Resource = load(path)

	var script_instance = script_res.new()
	print("DEBUG: script_instance created: %s" % str(script_instance))

	print("DEBUG: running script_instance.run(self)")
	script_instance.run(self)

	# NEW: look at _steps, not just _current_lines
	print("DEBUG: steps collected: %d" % _steps.size())

	if _steps.is_empty():
		print("DEBUG: no steps in script; finishing dialogue")
		_finish_dialogue()
		return

	# If you pause gameplay for dialogue, you can do that here
	# get_tree().paused = true

	# Start our step-based playback: move → line → move → line…
	_start_sequence()


func _finish_dialogue() -> void:
	if _dialog_ui != null and _dialog_ui.has_method("close"):
		_dialog_ui.close()
	else:
		on_dialogue_finished()


func on_dialogue_finished() -> void:
	_state = State.IDLE
	_current_lines.clear()
	_current_script_id = ""


# --------------------------------------------------------------
# Character registry (so actions can find real nodes)
# --------------------------------------------------------------

func register_character(character_id: String, node: Node) -> void:
	# Example: register_character("swordsman", player_node)
	if node == null:
		return
	_character_registry[character_id] = node


func unregister_character(character_id: String, node: Node) -> void:
	if !_character_registry.has(character_id):
		return
	if _character_registry[character_id] == node:
		_character_registry.erase(character_id)


func _get_character_node(character_id: String) -> Node:
	# 1) Registry lookup
	if _character_registry.has(character_id):
		return _character_registry[character_id]

	# 2) Fallback: try to find by group (if you use groups)
	# e.g. Characters may be in group "character", with an exported "character_id" var.
	for n in get_tree().get_nodes_in_group("character"):
		if n.has_meta("character_id") and n.get_meta("character_id") == character_id:
			_character_registry[character_id] = n
			return n

	# 3) Extra fallback: if this is the player and you only have one
	if character_id == "player" or character_id == "swordsman":
		var player_node := get_tree().get_first_node_in_group("player")
		if player_node != null:
			_character_registry[character_id] = player_node
			return player_node

	return null



# --------------------------------------------------------------
# API used BY dialogue scripts
# --------------------------------------------------------------

func clear_steps() -> void:
	_current_lines.clear()
	_steps.clear()
	_step_index = 0



func speak(character_id: String, text: String, overrides: Dictionary = {}) -> void:
	var speaker_side: String = ""
	if character_id == _left_character_id:
		speaker_side = "player1"
	elif character_id == _right_character_id:
		speaker_side = "player2"

	var merged_overrides: Dictionary = overrides.duplicate()
	if character_id != "":
		merged_overrides["portrait_name"] = character_id

	var line: Dictionary = {
		"text": text,
		"speaker": speaker_side,
		"overrides": merged_overrides,
	}

	# OLD behavior (your existing UI might still use this):
	_current_lines.append(line)

	# NEW behavior used by the cutscene step runner:
	var step := {
		"kind": "line",
		"speaker": speaker_side,
		"text": text,
		"overrides": merged_overrides,
	}
	_steps.append(step)





func narrate(text: String, overrides: Dictionary = {}) -> void:
	var line := {
		"text": text,
		"speaker": "",
		"overrides": overrides,
	}
	_current_lines.append(line)

	var step := {
		"kind": "line",
		"speaker": "",
		"text": text,
		"overrides": overrides,
	}
	_steps.append(step)



func set_speakers(left_id: String, right_id: String) -> void:
	# Example: left_id = "swordsman", right_id = "shadowman"
	_left_character_id = left_id
	_right_character_id = right_id


func set_script_mapping(mapping: Dictionary) -> void:
	# Optional: allow setting mappings from outside.
	_script_paths = mapping
	
# --- NEW: Cutscene-style actions from dialogue scripts --- #
# Usage from script:
#   orchestrator.action("swordsman", "move", Vector2(500, 200))
#   orchestrator.action("swordsman", "face", "right")
#   orchestrator.action("swordsman", "attack")
func action(
	character_id: String,
	action_type: String,
	arg1: Variant = null,
	arg2: Variant = null,
	arg3: Variant = null
) -> void:
	var step := {
		"kind": "action",
		"character_id": character_id,
		"action_type": action_type,
		"arg1": arg1,
		"arg2": arg2,
		"arg3": arg3,
	}
	_steps.append(step)

func _start_sequence() -> void:
	if _steps.is_empty():
		_finish_dialogue()
		return

	_step_index = 0
	_play_next_step()

func _play_next_step() -> void:
	if _step_index >= _steps.size():
		_finish_dialogue()
		return

	var step = _steps[_step_index]
	_step_index += 1

	match step["kind"]:
		"line":
			_show_line_step(step)
		"action":
			_run_action_step(step)
		_:
			# Unknown step kind; skip
			_play_next_step()

func _show_line_step(step: Dictionary) -> void:
	if _dialog_ui == null:
		push_warning("DialogueOrchestrator: _dialog_ui is null in _show_line_step")
		_play_next_step()
		return

	_dialog_ui.show_line(step["speaker"], step["text"], step["overrides"])
	# Do NOT call _play_next_step() here; we wait for DialogUI to emit line_finished

func set_dialog_ui(ui: Node) -> void:
	_dialog_ui = ui
	if ui != null and not ui.is_connected("line_finished", Callable(self, "_on_line_finished")):
		ui.connect("line_finished", Callable(self, "_on_line_finished"))

func _on_line_finished() -> void:
	_play_next_step()

func _run_action_step(step: Dictionary) -> void:
	var character_id: String = step["character_id"]
	var action_type: String = step["action_type"]
	var arg1 = step["arg1"]
	var arg2 = step["arg2"]
	var arg3 = step["arg3"]

	var target := _get_character_node(character_id)
	if target == null:
		push_warning("DialogueOrchestrator: Could not resolve character_id '%s'" % character_id)
		_play_next_step()
		return

	match action_type:
		"move":
			var dest: Vector2 = arg1
			var speed: float = (arg2 if typeof(arg2) == TYPE_FLOAT else 140.0)
			var facing_override: String = ""
			if typeof(arg3) == TYPE_STRING:
				facing_override = String(arg3)
			_run_blocking_move(target, dest, speed, facing_override)
		"face":
			_do_face_action(target, str(arg1))
			# face is instant – go to next step immediately
			_play_next_step()
		"attack":
			_do_attack_action(target)
			# attack might be instant trigger too
			_play_next_step()
		_:
			push_warning("DialogueOrchestrator: Unknown action_type '%s'" % action_type)
			_play_next_step()

func _run_blocking_move(target: Node, dest: Vector2, speed: float, facing_override: String = "") -> void:
	# Hide only the dialogue box while the character moves
	if _dialog_ui != null and _dialog_ui.has_method("set_box_visible"):
		_dialog_ui.set_box_visible(false)

	if target is CharacterBody2D:
		var body := target as CharacterBody2D
		body.velocity = Vector2.ZERO

	var current_pos: Vector2 = target.global_position
	var distance: float = current_pos.distance_to(dest)
	if distance < 1.0:
		# Already basically there; re-show box and continue
		if _dialog_ui != null and _dialog_ui.has_method("set_box_visible"):
			_dialog_ui.set_box_visible(true)
		_play_next_step()
		return

	# Determine which direction we should face while moving
	var dir_str := facing_override.to_lower()
	if dir_str == "":
		var delta: Vector2 = dest - current_pos
		# Pick the dominant axis to decide facing
		if abs(delta.x) >= abs(delta.y):
			dir_str = "right" if delta.x >= 0.0 else "left"
		else:
			dir_str = "down" if delta.y >= 0.0 else "up"

	# Face in that direction before we start moving
	_do_face_action(target, dir_str)

	# Optional hook: let the character play a walking animation
	if target.has_method("begin_cutscene_walk"):
		target.begin_cutscene_walk(dir_str)

	var duration: float = distance / max(speed, 1.0)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(target, "global_position", dest, duration)

	# When movement finishes, re-show box, keep facing that way, and stop walking anim
	tween.finished.connect(func() -> void:
		_do_face_action(target, dir_str)
		if _dialog_ui != null and _dialog_ui.has_method("set_box_visible"):
			_dialog_ui.set_box_visible(true)
		if target.has_method("end_cutscene_walk"):
			target.end_cutscene_walk()
		_play_next_step()
	)





func _do_move_action(target: Node, dest: Vector2, speed: float) -> void:
	if target == null:
		return

	# If the target is a CharacterBody2D, we can safely clear velocity
	if target is CharacterBody2D:
		var body := target as CharacterBody2D
		body.velocity = Vector2.ZERO

	var current_pos: Vector2 = target.global_position
	var distance: float = current_pos.distance_to(dest)
	if distance < 1.0:
		return

	var duration: float = distance / max(speed, 1.0)

	var tween := create_tween()
	# ⬇️ This is the important line: make tween run even while the tree is paused
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) 

	tween.tween_property(target, "global_position", dest, duration)


func _do_face_action(target: Node, dir: String) -> void:
	if target == null:
		return

	var facing_enum_value: int = -1

	# Try to map string -> Character.Facing enum
	match dir:
		"up":
			if Character.Facing.has("UP"):
				facing_enum_value = Character.Facing.UP
		"down":
			if Character.Facing.has("DOWN"):
				facing_enum_value = Character.Facing.DOWN
		"left":
			if Character.Facing.has("LEFT"):
				facing_enum_value = Character.Facing.LEFT
		"right":
			if Character.Facing.has("RIGHT"):
				facing_enum_value = Character.Facing.RIGHT

	if facing_enum_value == -1:
		push_warning("DialogueOrchestrator._do_face_action: Unknown direction '%s'" % dir)
		return

	# Prefer the Character API
	if target.has_method("change_facing"):
		target.change_facing(facing_enum_value)
	elif target is Character:
		var c := target as Character
		c.facing = facing_enum_value
	else:
		push_warning("DialogueOrchestrator._do_face_action: target has no facing API")


func _do_attack_action(target: Node) -> void:
	if target == null:
		return

	# Let Player / NPCs decide how to respond to this call.
	# We'll try a few conventions so you can wire things your way.
	if target.has_method("play_attack_from_dialogue"):
		target.play_attack_from_dialogue()
	elif target.has_method("attack"):
		target.attack()
	elif target.has_method("start_attack"):
		target.start_attack()
	else:
		push_warning("DialogueOrchestrator._do_attack_action: target has no attack method (expected play_attack_from_dialogue/attack/start_attack)")
