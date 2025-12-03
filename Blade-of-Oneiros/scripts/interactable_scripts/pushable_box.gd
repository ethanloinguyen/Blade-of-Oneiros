class_name PushableBox
extends CharacterBody2D

@export var gap: float = 1.0              
@export var move_speed: float = 60.0      
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var is_moving: bool = false
var box_step: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	#We want to use the box's collision shape as the grid/step size, to make puzzle pushes strict
	var rect_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D
	var size: Vector2 = rect_shape.size * global_scale
	
	box_step = size + Vector2(gap, gap)

	#Snap starting position to the box grid
	var snapped_x: float = round(global_position.x / box_step.x) * box_step.x
	var snapped_y: float = round(global_position.y / box_step.y) * box_step.y
	global_position = Vector2(snapped_x, snapped_y)
	target_pos = global_position


func _physics_process(delta: float) -> void:
	if is_moving:
		var to_target: Vector2 = target_pos - global_position
		var distance: float = to_target.length()

		if distance <= move_speed * delta:
			global_position = target_pos
			is_moving = false

		else:
			var direction: Vector2 = to_target / distance
			var motion: Vector2 = direction * move_speed * delta
			move_and_collide(motion)


func push(raw_dir: Vector2) -> bool:
	if is_moving:
		return false

	var direction: Vector2 = DirectionSnap._snap_to_cardinal(raw_dir)
	if direction == Vector2.ZERO:
		return false

	var motion: Vector2
	if direction.x != 0.0:
		motion = Vector2(sign(direction.x) * box_step.x, 0.0)
	else:
		motion = Vector2(0.0, sign(direction.y) * box_step.y)

	var from_transform: Transform2D = global_transform

	if test_move(from_transform, motion):
		return false

	target_pos = global_position + motion
	is_moving = true
	return true
