class_name Level
extends Node2D

#Edited by ALfred
func _ready() -> void:
	var ui := find_child("DialogUI", true, false)
	if ui:
		print("DEBUG: level.gd found DialogUI at:", ui.get_path())
		DialogueOrchestrator.set_dialog_ui(ui)
	else:
		print("DEBUG: level.gd could NOT find DialogUI anywhere under this level node")
