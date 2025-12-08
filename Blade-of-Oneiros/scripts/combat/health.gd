class_name Health
extends Area2D

signal hurt
signal died

@export var max_health:int

var current_health:int

func _ready() -> void:
	current_health = max_health


func set_invincible(state: bool):
	var collision = $CollisionShape2D
	collision.disabled = state


func take_damage(amount:int):
	if is_dead(): # prevent double death
		return
	current_health -= amount
	emit_signal("hurt")
	if is_dead():
		emit_signal("died")


func is_dead():
	return current_health <= 0
