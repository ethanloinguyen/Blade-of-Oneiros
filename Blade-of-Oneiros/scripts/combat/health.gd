class_name Health
extends Area2D

signal died

@export var max_health:int

var current_health:int

func _ready() -> void:
	current_health = max_health


func take_damage(amount:int):
	current_health -= amount
	if current_health <= 0:
		emit_signal("died")
