class_name Hitbox
extends Area2D

@export var damage:int
@export var activate_animation:String
@export var animation_delay:float


# activate hitbox and aim in a direction
func activate(dir:Vector2, rotate_hitbox:bool) -> void:
	if rotate_hitbox:
		global_rotation = dir.angle()
	for a in get_overlapping_areas():
		if a is Health:
			a.take_damage(damage)
			print(a.get_parent().name + " took damage and is at " + str(a.current_health))


func activate_from_dir(dir:String, rotate_hitbox:bool):
	match dir:
		"right":
			activate(Vector2.RIGHT, rotate_hitbox)
		"left":
			activate(Vector2.LEFT, rotate_hitbox)
		"up":
			activate(Vector2.UP, rotate_hitbox)
		"down":
			activate(Vector2.DOWN, rotate_hitbox)


func attach_signal(animation_player, rotate_hitbox:bool):
	if animation_player is AnimatedSprite2D:
		animation_player.frame_changed.connect(func():
			if animation_player.animation.begins_with(activate_animation) and animation_player.frame == floor(animation_delay):
				var dir = animation_player.animation.split("_")[-1]
				activate_from_dir(dir, rotate_hitbox)
		)
