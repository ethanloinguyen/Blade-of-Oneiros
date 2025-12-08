class_name FallingCutscene
extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var falling_voices: Array[AudioStream] = []

var player: Player


func _ready() -> void:
	if camera:
		camera.enabled = true
	hud.visible = false
	anim.play("fall")

	var stream := falling_voices[randi() % falling_voices.size()]
	audio.stream = stream
	audio.play()
	anim.animation_finished.connect(_on_anim_finished)


func _on_anim_finished(_anim_name: StringName) -> void:
	player.dead = true
	player.set_health_bar()
	GameState.game_over = true
	get_tree().change_scene_to_file("res://scenes/death_scene/death_screen.tscn")
	queue_free()
