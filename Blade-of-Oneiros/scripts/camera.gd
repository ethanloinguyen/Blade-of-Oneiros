class_name Camera
extends Camera2D

@export var max_look_ahead:float = 48.0
@export var look_ahead_speed:float = 8.0
@export var min_speed: float = 10.0
@onready var player: CharacterBody2D = get_parent()

var screenshake:float

var _current_look_ahead: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var velocity: Vector2 = player.velocity
	
	var target_offset: Vector2 = Vector2.ZERO
	
	if velocity.length() > min_speed:
		target_offset = velocity.normalized() * max_look_ahead
		
	_current_look_ahead = _current_look_ahead.lerp(target_offset, look_ahead_speed*delta)

	# screenshake (by ben)
	var screenshake_offset:Vector2 = Vector2(randf(), randf()).normalized() * screenshake


	offset = _current_look_ahead + screenshake_offset
	
	
func snap_to_player() -> void:

	reset_smoothing()
