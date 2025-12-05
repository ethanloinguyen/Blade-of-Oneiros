class_name BarredDoor
extends Node2D


var is_open: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _ready() -> void:
	pass


func _open() -> void:
	animation_player.play("open")
	pass
	

func _close() -> void:
	animation_player.play("closed")
	pass
	


#func _on_lever_activated() -> void:
	#pass # Replace with function body.
