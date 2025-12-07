extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio2: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var audio3: AudioStreamPlayer2D = $AudioStreamPlayer2D3
@onready var audio4: AudioStreamPlayer2D = $AudioStreamPlayer2D4
@export var falling_voices: AudioStream
@export var falling_voices2: AudioStream
@export var falling_voices3: AudioStream
@export var falling_voices4: AudioStream
func _ready() -> void:
	if camera:
		camera.enabled = true
	anim.play("fall")
	audio.stream = falling_voices
	audio.play()
	audio2.stream = falling_voices2
	audio2.play()
	audio3.stream = falling_voices3
	audio3.play()
	audio4.stream = falling_voices4
	audio4.play()
	anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(name: StringName) -> void:
	if name != "fall":
		return

	queue_free()
