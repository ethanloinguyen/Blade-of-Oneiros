class_name TestPlayer
extends CharacterBody2D

@export var speed:float


func _physics_process(_delta:float) -> void:
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()q
