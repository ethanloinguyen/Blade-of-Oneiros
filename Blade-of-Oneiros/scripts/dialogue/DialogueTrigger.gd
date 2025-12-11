#Used by Area2Ds to call the dialogue orchestrator
extends Area2D
class_name DialogueTrigger

@export var dialogue_id: String = ""

var _player_inside: bool = false

func _ready() -> void:
	print("DialogueTrigger READY: ", name)
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))



func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print ("playerin")
		print("DEBUG: interact pressed inside trigger; dialogue_id = ", dialogue_id)

		if DialogueOrchestrator.is_dialogue_active():
			print("DEBUG: dialogue already active, ignoring start()")
			return

		print("DEBUG: calling DialogueOrchestrator.start(...)")
		DialogueOrchestrator.start(dialogue_id)
		get_viewport().set_input_as_handled()
		_player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("playerout")
		_player_inside = false


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return

	if dialogue_id == "":
		return

	if event.is_action_pressed("interact"):
		print("DEBUG: interact pressed inside trigger; dialogue_id = ", dialogue_id)

		if DialogueOrchestrator.is_dialogue_active():
			print("DEBUG: dialogue already active, ignoring start()")
			return

		print("DEBUG: calling DialogueOrchestrator.start(...)")
		DialogueOrchestrator.start(dialogue_id)
		get_viewport().set_input_as_handled()
