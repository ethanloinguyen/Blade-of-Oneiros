class_name Hitbox
extends Area2D

@export var damage:int
@export var activate_animation:String
@export var activate_frame:int


# activate hitbox and aim in a direction
func _activate(dir:Vector2) -> void:
	global_rotation = dir.angle()
	for a in get_overlapping_areas():
		if a is Health:
			a.current_health -= damage


func attach_signal(sprite:AnimatedSprite2D):
	sprite.frame_changed.connect(func():
		if sprite.animation.begins_with(activate_animation) and sprite.frame == activate_frame:
			var dir = sprite.animation.split("_")[-1]
			match dir:
				"right":
					_activate(Vector2.RIGHT)
				"left":
					_activate(Vector2.LEFT)
				"up":
					_activate(Vector2.UP)
				"down":
					_activate(Vector2.DOWN)
	)
