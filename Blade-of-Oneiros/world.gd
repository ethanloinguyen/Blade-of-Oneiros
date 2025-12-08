extends Node

func _ready() -> void:
	# Defer so all child scenes (lvl_1, HUD, etc.) have fully loaded
	call_deferred("_register_dialog_ui")


func _register_dialog_ui() -> void:
	print("DEBUG: World._register_dialog_ui starting; printing tree:")
	print_tree()

	var ui := get_tree().root.find_child("DialogUI", true, false)
	if ui:
		print("DEBUG: World found DialogUI at path:", ui.get_path())
		DialogueOrchestrator.set_dialog_ui(ui)
	else:
		print("DEBUG: World could NOT find any node named DialogUI in the tree")
