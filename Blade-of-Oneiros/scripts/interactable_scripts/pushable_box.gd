class_name PushableBox
extends RigidBody2D


@export var push_speed : float = 30.0
var push_direction : Vector2 = Vector2.ZERO

@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D


func _physics_process(_delta: float) -> void:
	if push_direction == Vector2.ZERO:
		linear_velocity = Vector2.ZERO	
	else:
		linear_velocity = push_direction * push_speed
		
		
func _set_push(value: Vector2) -> void:
	push_direction = value
	
