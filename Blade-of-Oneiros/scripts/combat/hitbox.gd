class_name Hitbox
extends Area2D

@export var damage:int
@export var activate_animation:String
@export var animation_delay:float


# activate hitbox and aim in a direction
func activate(dir:Vector2) -> void:
	global_rotation = dir.angle()
	for a in get_overlapping_areas():
		if a is Health:
			a.take_damage(damage)


func activate_from_dir(dir:String):
	match dir:
		"right":
			activate(Vector2.RIGHT)
		"left":
			activate(Vector2.LEFT)
		"up":
			activate(Vector2.UP)
		"down":
			activate(Vector2.DOWN)


func attach_signal(animation_player):
	if animation_player is AnimatedSprite2D:
		animation_player.frame_changed.connect(func():
			if animation_player.animation.begins_with(activate_animation) and animation_player.frame == floor(animation_delay):
				var dir = animation_player.animation.split("_")[-1]
				activate_from_dir(dir)
		)
