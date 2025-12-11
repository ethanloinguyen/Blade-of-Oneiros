class_name Level
extends Node2D
@onready var audio = $AudioStreamPlayer2D
@export var music_audio: AudioStream

#Edited by ALfred
func _ready() -> void:
	music_audio.loop = true
	play_audio(music_audio)
	var ui := find_child("DialogUI", true, false)
	if ui:
		print("DEBUG: level.gd found DialogUI at:", ui.get_path())
		DialogueOrchestrator.set_dialog_ui(ui)
	else:
		print("DEBUG: level.gd could NOT find DialogUI anywhere under this level node")

func play_audio(_stream : AudioStream) -> void:

	audio.stream = _stream
	audio.play()	
