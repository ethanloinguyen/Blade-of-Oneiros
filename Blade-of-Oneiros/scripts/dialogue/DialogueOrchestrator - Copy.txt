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

# Camera handling for cutscenes
var _original_camera: Camera2D = null
var _cutscene_camera: Camera2D = null

# Optional: if other systems want to listen for cutscene actions
signal action_enqueued(character_id: String, action_type: String, payload: Dictionary)

# Map dialogue IDs to script resource paths.
# You can fill this in code or via an exported Dictionary if you prefer.
var _script_paths: Dictionary = {
	"npc_intro_1": "res://scripts/dialogue/scripts/dialogue_script_intro.gd",
	"npc_intro_2": "res://scripts/dialogue/scripts/dialogue_script_intro_2.gd",
	"tutorial_cutscene": "res://scripts/dialogue/scripts/dialogue_script_tutorial_cutscene.gd",
	"boss_fight": "res://scripts/dialogue/scripts/dialogue_script_boss_intro.gd"
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
		# Try the self-registration first (in case DialogUI loaded after us)
		var found := get_tree().root.find_child("DialogUI", true, false)
		if found == null:
			push_warning("DialogueOrchestrator: DialogUI not found; cannot start dialogue.")
			print("DEBUG: _dialog_ui is STILL NULL after re-search")
			return
		set_dialog_ui(found)

	if dialogue_id == "tutorial_cutscene" \
			and GameState.start_with_opening_tutorial \
			and _dialog_ui != null \
			and _dialog_ui.has_method("force_black_start_from_gamestate"):
		_dialog_ui.force_black_start_from_gamestate()

	print("DEBUG: _dialog_ui is valid: ", _dialog_ui)


	_current_script_id = dialogue_id
	_current_lines.clear()
	_steps.clear()
	_step_index = 0
	_state = State.RUNNING_SCRIPT

	# Reset camera state for this run
	_original_camera = null
	_cutscene_camera = null

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
	# Make sure we restore the camera when the dialogue is completely over
	_do_camera_restore()

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
	# 1) Registry lookup with validity check
	if _character_registry.has(character_id):
		var cached = _character_registry[character_id]
		# Make sure the cached node hasn't been freed
		if is_instance_valid(cached):
			return cached
		# If it's stale, drop it so we can re-resolve
		_character_registry.erase(character_id)

	# 2) Fallback: try to find by group "character"
	for n in get_tree().get_nodes_in_group("character"):
		if is_instance_valid(n) and n.has_meta("character_id") and n.get_meta("character_id") == character_id:
			_character_registry[character_id] = n
			return n

	# 3) Extra fallback: player / swordsman group
	if character_id == "player" or character_id == "swordsman":
		var player_node := get_tree().get_first_node_in_group("player")
		if player_node != null and is_instance_valid(player_node):
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
func npc_disappear(duration: float = 0.5) -> void:
	action("oldmansmiles", "npc_disappear", duration)


# --- Helper: fade screen to black ---
func fade_out(duration: float = 1.0) -> void:
	var step := {
		"kind": "fade",
		"direction": "out",
		"duration": duration,
	}
	_steps.append(step)



# --- Helper: fade screen from black to clear ---
func fade_in(duration: float = 1.0) -> void:
	var step := {
		"kind": "fade",
		"direction": "in",
		"duration": duration,
	}
	_steps.append(step)


func narrate(text: String, overrides: Dictionary = {}) -> void:
	overrides["is_narration"] = true   # <<< add this
	
	var line := {
		"text": text,
		"speaker": "",
		"overrides": overrides,
		"is_narration": true,   # <-- NEW FLAG
	}
	_current_lines.append(line)

	var step := {
		"kind": "line",
		"speaker": "",
		"text": text,
		"overrides": overrides,
		"is_narration": true,   # <-- NEW FLAG
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
		"fade":
			_run_fade_step(step)
		"camera":
			_run_camera_step(step)
		_:
			# Unknown step kind; skip
			_play_next_step()

func _show_line_step(step: Dictionary) -> void:
	if _dialog_ui == null:
		push_warning("DialogueOrchestrator: _dialog_ui is null in _show_line_step")
		_play_next_step()
		return

	var speaker: String = step.get("speaker", "")
	var text: String = step.get("text", "")
	var overrides: Dictionary = step.get("overrides", {}).duplicate()

	# Bridge top-level flag into overrides so DialogUI can see it
	if step.get("is_narration", false):
		overrides["is_narration"] = true

	_dialog_ui.show_line(speaker, text, overrides)
	# Do NOT call _play_next_step() here; we wait for DialogUI to emit line_finished

func npc_appear(duration: float = 0.5) -> void:
	action("oldmansmiles", "npc_appear", duration)


func npc_moveto(dest: Vector2, facing: String = "") -> void:
	var speed: float = 140.0
	action("oldmansmiles", "move", dest, speed, facing)


func npc_face(facing: String) -> void:
	action("oldmansmiles", "face", facing)

func camera_switch_to(camera_path: Variant) -> void:
	var step := {
		"kind": "camera",
		"camera_action": "switch",
		"camera_path": camera_path,
	}
	_steps.append(step)


func camera_restore() -> void:
	var step := {
		"kind": "camera",
		"camera_action": "restore",
	}
	_steps.append(step)


func set_dialog_ui(ui: Node) -> void:
	_dialog_ui = ui
	print("DEBUG: set_dialog_ui called, ui =", ui)
	if ui != null and not ui.is_connected("line_finished", Callable(self, "_on_line_finished")):
		ui.connect("line_finished", Callable(self, "_on_line_finished"))


func _on_line_finished() -> void:
	_play_next_step()

func _run_npc_appear(target: Node, duration: float) -> void:
	if target == null:
		_play_next_step()
		return

	# Let the NPC script handle the actual fade logic.
	if target.has_method("appear_from_dialogue"):
		var tween: Tween = target.appear_from_dialogue(duration)
		if tween:
			# Wait for the fade to finish, then continue the sequence
			tween.finished.connect(Callable(self, "_play_next_step"))
		else:
			_play_next_step()
	else:
		# Fallback: just pop him in instantly
		target.modulate.a = 1.0
		target.visible = true
		_play_next_step()

func _run_npc_disappear(target: Node, duration: float) -> void:
	if target == null:
		_play_next_step()
		return

	if target.has_method("disappear_from_dialogue"):
		var tween: Tween = target.disappear_from_dialogue(duration)
		if tween:
			tween.finished.connect(Callable(self, "_play_next_step"))
		else:
			_play_next_step()
	else:
		# Fallback: hide instantly
		target.modulate.a = 0.0
		target.visible = false
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
		"npc_appear":
			var duration: float = (arg1 if typeof(arg1) == TYPE_FLOAT else 0.5)
			_run_npc_appear(target, duration)
		"npc_disappear":
			var duration: float = (arg1 if typeof(arg1) == TYPE_FLOAT else 0.5)
			_run_npc_disappear(target, duration)
		"camera":
			_run_camera_step(step)
		_:
			push_warning("DialogueOrchestrator: Unknown action_type '%s'" % action_type)
			_play_next_step()

func _run_fade_step(step: Dictionary) -> void:
	if _dialog_ui == null:
		push_warning("DialogueOrchestrator: _dialog_ui is null in _run_fade_step")
		_play_next_step()
		return

	var dir: String = step.get("direction", "out")
	var duration: float = float(step.get("duration", 1.0))

	# Ensure we only have one connection at a time
	if not _dialog_ui.is_connected("fade_finished", Callable(self, "_on_fade_finished")):
		_dialog_ui.connect("fade_finished", Callable(self, "_on_fade_finished"))

	match dir:
		"out":
			if _dialog_ui.has_method("fade_out"):
				_dialog_ui.fade_out(duration)
			else:
				push_warning("DialogueOrchestrator: DialogUI has no fade_out() method")
				_play_next_step()
		"in":
			if _dialog_ui.has_method("fade_in"):
				_dialog_ui.fade_in(duration)
			else:
				push_warning("DialogueOrchestrator: DialogUI has no fade_in() method")
				_play_next_step()
		_:
			push_warning("DialogueOrchestrator: Unknown fade direction '%s'" % dir)
			_play_next_step()


func _on_fade_finished() -> void:
	if _dialog_ui != null and _dialog_ui.is_connected("fade_finished", Callable(self, "_on_fade_finished")):
		_dialog_ui.disconnect("fade_finished", Callable(self, "_on_fade_finished"))

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
func _run_camera_step(step: Dictionary) -> void:
	var action: String = step.get("camera_action", "")
	match action:
		"switch":
			_do_camera_switch(step.get("camera_path"))
		"restore":
			_do_camera_restore()
		_:
			push_warning("DialogueOrchestrator: Unknown camera_action '%s'" % action)

	# Camera changes are instantaneous; go straight to next step
	_play_next_step()


func _do_camera_switch(camera_path: Variant) -> void:
	var viewport := get_viewport()
	if viewport == null:
		print("DEBUG camera: no viewport")
		return

	# Cache the original camera the first time we ever switch
	if _original_camera == null:
		_original_camera = viewport.get_camera_2d()
		if _original_camera != null:
			print("DEBUG camera: original camera is", _original_camera.get_path())
		else:
			print("DEBUG camera: original camera is NULL")

	var cam: Camera2D = null

	# --- Resolve the target camera ---
	if camera_path is Camera2D:
		cam = camera_path
	elif camera_path is String or camera_path is NodePath:
		var path_str := str(camera_path)
		var root := get_tree().current_scene

		# 1) Absolute from /root
		if path_str.begins_with("/"):
			cam = get_node_or_null(path_str) as Camera2D

		# 2) Relative to current scene (e.g. "BossCutsceneCam")
		if cam == null and root != null:
			cam = root.get_node_or_null(path_str) as Camera2D

		# 3) Relative to /root, if current_scene is something else
		if cam == null:
			cam = get_tree().root.get_node_or_null(path_str) as Camera2D

		# 4) Last resort: search entire tree by name
		if cam == null:
			cam = get_tree().root.find_child(path_str, true, false) as Camera2D

	if cam == null:
		push_warning("DialogueOrchestrator: camera_switch_to could not find camera at %s" % str(camera_path))
		print("DEBUG camera: could not resolve camera for path:", camera_path)
		return

	_cutscene_camera = cam
	print("DEBUG camera: switching to cutscene camera", cam.get_path())

	# Godot 4: enable this camera and disable the original
	if _original_camera != null and is_instance_valid(_original_camera):
		_original_camera.enabled = false

	_cutscene_camera.enabled = true
	_cutscene_camera.make_current()


func _do_camera_restore() -> void:
	if _cutscene_camera != null and is_instance_valid(_cutscene_camera):
		print("DEBUG camera: disabling cutscene camera", _cutscene_camera.get_path())
		_cutscene_camera.enabled = false

	if _original_camera != null and is_instance_valid(_original_camera):
		print("DEBUG camera: restoring original camera", _original_camera.get_path())
		_original_camera.enabled = true
		_original_camera.make_current()
	else:
		print("DEBUG camera: no original camera to restore")

	_cutscene_camera = null



func multi_voice_narrate(voices: Array, overrides: Dictionary = {}) -> void:
	var merged := overrides.duplicate()
	merged["multi_voice"] = true
	merged["voices"] = voices

	# Main text can safely be ""
	narrate("", merged)

func multi_voice_speak(character_id: String, voices: Array, overrides: Dictionary = {}) -> void:
	var merged := overrides.duplicate()
	merged["multi_voice"] = true
	merged["voices"] = voices
	
	speak(character_id, "", merged)



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
