class_name BarredDoor
extends Node2D


var is_open: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var start_open: bool = false


func _ready() -> void:
	if start_open:
		is_open = true
		animation_player.play("open")
	else:
		is_open = false
		animation_player.play("closed")

	pass


func _open() -> void:
	animation_player.play("open")
	pass
	

func _close() -> void:
	animation_player.play("closed")
	pass
	
