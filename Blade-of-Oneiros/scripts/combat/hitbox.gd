class_name Hitbox
extends Area2D

@export var damage:int


# activate hitbox for 1 physics frame
func activate() -> void:
	for a in get_overlapping_areas():
		if a is Health:
			a.current_health -= damage
