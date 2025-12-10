class_name Hitbox
extends Area2D

@export var damage:int
@export var activate_animation:String
@export var animation_delay:float
@export var hitstop_duration:float

var _hit_something = false

# activate hitbox and aim in a direction
func activate(dir:Vector2, rotate_hitbox:bool, wait_for_delay:bool) -> void:
	_hit_something = false
	if rotate_hitbox:
		global_rotation = dir.angle()
	if wait_for_delay:
		await get_tree().create_timer(animation_delay, false).timeout
	for a in get_overlapping_areas():
		if a is Health:
			if not a.is_dead() and hitstop_duration > 0 and not _hit_something:
				# hitstop
				var parent = get_parent()
				var old_mode = parent.process_mode
				get_tree().paused = true
				parent.process_mode = PROCESS_MODE_INHERIT
				await get_tree().create_timer(hitstop_duration, true).timeout
				get_tree().paused = false
				parent.process_mode = old_mode

				# screenshake
				get_viewport().get_camera_2d().screenshake(1.0, 10)

			a.take_damage(damage)
			_hit_something = true



func activate_from_dir(dir:String, rotate_hitbox:bool, wait_for_delay:bool):
	match dir:
		"right":
			activate(Vector2.RIGHT, rotate_hitbox, wait_for_delay)
		"left":
			activate(Vector2.LEFT, rotate_hitbox, wait_for_delay)
		"up":
			activate(Vector2.UP, rotate_hitbox, wait_for_delay)
		"down":
			activate(Vector2.DOWN, rotate_hitbox, wait_for_delay)


func attach_signal(animation_player, rotate_hitbox:bool):
	if animation_player is AnimatedSprite2D:
		animation_player.frame_changed.connect(func():
			if animation_player.animation.begins_with(activate_animation) and animation_player.frame == floor(animation_delay):
				var dir = animation_player.animation.split("_")[-1]
				activate_from_dir(dir, rotate_hitbox, false)
		)
