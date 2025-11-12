class_name Hitbox
extends Area2D

@export var damage:int


# activate hitbox and aim in a direction
func activate(dir:Vector2) -> void:
	global_rotation = dir.angle()

	for a in get_overlapping_areas():
		if a is Health:
			a.current_health -= damage
