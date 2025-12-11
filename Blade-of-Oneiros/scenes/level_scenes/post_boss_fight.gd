extends Node2D  # or whatever this scene root is

func _ready() -> void:
	# Connect once, when the scene loads
	DialogueOrchestrator.dialogue_finished.connect(_on_dialogue_finished)
	print("connected Dialogueorchestrator")
	# Somewhere you start the boss intro:
	# DialogueOrchestrator.start("boss_intro")
	
func _on_dialogue_finished(_dialogue_id: String) -> void:
	GameState.game_finished = true
