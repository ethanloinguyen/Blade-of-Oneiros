extends Node2D

@onready var audio = $AudioStreamPlayer2D
@export var music_audio: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_audio.loop = true
	play_audio(music_audio)
	
func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()	
