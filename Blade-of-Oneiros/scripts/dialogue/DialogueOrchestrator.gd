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


# Map dialogue IDs to script resource paths.
# You can fill this in code or via an exported Dictionary if you prefer.
var _script_paths: Dictionary = {
	"npc_intro_1": "res://scripts/dialogue/scripts/dialogue_script_intro.gd",
}

func _ready() -> void:
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



func start(dialogue_id: String) -> void:
	print("DEBUG: DialogueOrchestrator.start called with id: ", dialogue_id)

	if _state != State.IDLE:
		print("DEBUG: state is not IDLE (", _state, "), aborting")
		return

	if !_script_paths.has(dialogue_id):
		push_warning("DialogueOrchestrator: No script found for id '%s'" % dialogue_id)
		print("DEBUG: _script_paths DOES NOT have key: ", dialogue_id)
		return
	print("DEBUG: _script_paths HAS key: ", dialogue_id)

	# 🔽 Re-resolve DialogUI if needed
	if _dialog_ui == null:
		_dialog_ui = get_tree().root.find_child("DialogUI", true, false)
		if _dialog_ui == null:
			push_warning("DialogueOrchestrator: DialogUI not found; cannot start dialogue.")
			print("DEBUG: _dialog_ui is STILL NULL after re-search")
			return

	print("DEBUG: _dialog_ui is valid: ", _dialog_ui)

	_current_script_id = dialogue_id
	_current_lines.clear()
	_state = State.RUNNING_SCRIPT

	var path: String = _script_paths[dialogue_id]
	print("DEBUG: loading script at path: ", path)
	var script_res: Resource = load(path)
	if script_res == null:
		push_warning("DialogueOrchestrator: Failed to load script at %s" % path)
		print("DEBUG: script_res is NULL")
		_state = State.IDLE
		return
	print("DEBUG: script_res loaded: ", script_res)

	var script_instance = script_res.new()
	print("DEBUG: script_instance created: ", script_instance)

	if !script_instance.has_method("run"):
		push_warning("DialogueOrchestrator: Script '%s' has no run(orchestrator) method." % dialogue_id)
		print("DEBUG: script_instance has NO run(orchestrator)")
		_state = State.IDLE
		return

	print("DEBUG: running script_instance.run(self)")
	script_instance.run(self)

	print("DEBUG: lines collected: ", _current_lines.size())
	if _current_lines.is_empty():
		print("DEBUG: no lines in script; resetting state to IDLE")
		_state = State.IDLE
		return

	if _dialog_ui.has_method("start_conversation"):
		print("DEBUG: calling DialogUI.start_conversation(...)")
		_dialog_ui.start_conversation(_current_lines)
	else:
		push_warning("DialogueOrchestrator: DialogUI has no start_conversation(lines) method.")
		print("DEBUG: DialogUI has no start_conversation")
		_state = State.IDLE



func on_dialogue_finished() -> void:
	_state = State.IDLE
	_current_lines.clear()
	_current_script_id = ""



# --------------------------------------------------------------
# API used BY dialogue scripts
# --------------------------------------------------------------

func clear_lines() -> void:
	_current_lines.clear()


func speak(character_id: String, text: String, overrides: Dictionary = {}) -> void:
	var speaker_side: String = ""
	if character_id == _left_character_id:
		speaker_side = "player1"  # left in DialogUI
	elif character_id == _right_character_id:
		speaker_side = "player2"  # right in DialogUI
	else:
		# Unknown speaker; you can treat this as narration
		speaker_side = ""

	# Copy overrides so we don't mutate the original
	var merged_overrides: Dictionary = overrides.duplicate()
	if character_id != "":
		# This tells DialogUI which portrait file to load
		merged_overrides["portrait_name"] = character_id

	var line: Dictionary = {
		"text": text,
		"speaker": speaker_side,
		"overrides": merged_overrides,
	}
	_current_lines.append(line)



func narrate(text: String, overrides: Dictionary = {}) -> void:
	# No speaker; useful for narration.
	var line: Dictionary = {
		"text": text,
		"overrides": overrides
	}
	_current_lines.append(line)

func set_speakers(left_id: String, right_id: String) -> void:
	# Example: left_id = "swordsman", right_id = "shadowman"
	_left_character_id = left_id
	_right_character_id = right_id


func set_script_mapping(mapping: Dictionary) -> void:
	# Optional: allow setting mappings from outside.
	_script_paths = mapping
