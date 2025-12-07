class_name Health
extends Area2D

signal hurt
signal died

@export var max_health:int

var current_health:int

func _ready() -> void:
	current_health = max_health


func take_damage(amount:int):
	current_health -= amount
	emit_signal("hurt")
	if is_dead():
		emit_signal("died")


func is_dead():
	return current_health <= 0
