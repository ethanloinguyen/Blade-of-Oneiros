class_name Door
extends StaticBody2D

@export var action: StringName = "interact"
@export var starts_open: bool = false
@export var requires_key: bool = false
@export var locked_sound: AudioStream
@export var open_sound: AudioStream
@export var single_use: bool = false

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var blocker: CollisionShape2D = $doorblock
@onready var area: Area2D = $Area2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


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
	if single_use:
		if not _is_open:
			open()
		return
	if event.is_action_pressed(action):
		if _is_open:
			close()
		else:
			open()
	
	
func open() -> void:
	if _is_open:
		return
	if requires_key:
		var key_used := false
		
		if Engine.has_singleton("Inventory"):
			var inv = Engine.get_singleton("Inventory")
			if inv and inv.has_method("use_key"):
				key_used = inv.use_key()
				
		if not key_used:
			_play_locked_sound()
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
	if single_use:
		return

	_is_open = false
	
	blocker.disabled = false
	if animation.has_animation("close"):
		animation.play("close")
	elif animation.has_animation("closed_idle"):
		animation.play("closed_idle")
		

func _play_locked_sound() -> void:
		audio_player.stream = locked_sound
		audio_player.play()
