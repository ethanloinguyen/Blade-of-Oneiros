extends Node2D  

func _ready() -> void:
	DialogueOrchestrator.dialogue_finished.connect(_on_dialogue_finished)
	print("connected Dialogueorchestrator")

	
func _on_dialogue_finished(_dialogue_id: String) -> void:
	GameState.game_finished = true
