class_name Door
extends StaticBody2D

@export var action: StringName = "interact"
@export var starts_open: bool = false

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var blocker: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D

var _player_near: bool = false
var _is_open: bool = false


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	set_process_unhandled_input(true)
	
	if starts_open:
		_is_open = true
		blocker.disabled = true
		if animation.has_animation("open_idle"):
			animation.play("open_idle")
	else:
		_is_open = false
		blocker.disabled = false
		if animation.has_animation("closed_idle"):
			animation.play("closed_idle")
		
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false


func _unhandled_input(event: InputEvent) -> void:
	if not _player_near:
		return
	if event.is_action_pressed(action):
		if _is_open:
			close()
		else:
			open()
	
	
func open() -> void:
	if _is_open:
		return
	_is_open = true
	
	blocker.disabled = true
	if animation.has_animation("open"):
		animation.play("open")
	elif animation.has_animation("open_idle"):
		animation.play("open_idle")
		

func close() -> void:
	if not _is_open:
		return
	_is_open = false
	
	blocker.disabled = false
	if animation.has_animation("close"):
		animation.play("close")
	elif animation.has_animation("closed_idle"):
		animation.play("closed_idle")
		
