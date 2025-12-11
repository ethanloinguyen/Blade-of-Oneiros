extends Node2D  # or whatever this scene root is

func _ready() -> void:
	# Connect once, when the scene loads
	DialogueOrchestrator.dialogue_finished.connect(_on_dialogue_finished)
	print("connected Dialogueorchestrator")
	# Somewhere you start the boss intro:
	# DialogueOrchestrator.start("boss_intro")
	
func _on_dialogue_finished(_dialogue_id: String) -> void:
	PlayerManagement.change_level("res://scenes/level_scenes/boss_fight.tscn", "boss")
	await SceneTransition.fade_in()
