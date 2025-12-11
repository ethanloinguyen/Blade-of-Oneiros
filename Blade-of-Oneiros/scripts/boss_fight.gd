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
	_fade_in_audio(3) 

func _fade_in_audio(duration := 1.5):
	audio.volume_db = -40.0   # start very quiet
	audio.play()

	var tween := get_tree().create_tween()
	tween.tween_property(audio, "volume_db", 0.0, duration)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
