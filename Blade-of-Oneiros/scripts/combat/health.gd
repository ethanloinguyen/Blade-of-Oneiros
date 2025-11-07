class_name Health
extends Area2D

@export var max_health:int

var current_health:int

func _ready() -> void:
	current_health = max_health
	area_entered.connect(func(a):
		if a is Hitbox:
			current_health -= a.damage
	)
