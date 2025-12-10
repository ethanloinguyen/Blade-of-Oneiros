class_name Guards
extends Node2D

@onready var guards: Array[Sprite2D] = [
	$guard1,
	$guard2,
	$guard3,
	$guard4,
]

@onready var blocker: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var walk: AudioStream

func _ready() -> void:
	audio.stream = walk


func dismiss_guards() -> void:

	for g in guards:
		g.visible = false

	blocker.disabled = true
	

	if audio.stream:
		audio.play()
