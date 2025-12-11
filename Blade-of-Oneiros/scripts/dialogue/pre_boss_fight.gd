extends Node2D 

func _ready() -> void:

	DialogueOrchestrator.dialogue_finished.connect(_on_dialogue_finished)
	print("connected Dialogueorchestrator")
	
func _on_dialogue_finished(_dialogue_id: String) -> void:
	PlayerManagement.change_level("res://scenes/level_scenes/boss_fight.tscn", "boss")
	await SceneTransition.fade_in()
