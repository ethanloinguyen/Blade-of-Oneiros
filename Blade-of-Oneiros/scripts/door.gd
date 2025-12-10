class_name Door
extends StaticBody2D

@export var action: StringName = "interact"
@export var starts_open: bool = false
@export var requires_key: bool = false
@export var locked_sound: AudioStream
@export var open_sound: AudioStream
@export var single_use: bool = false
@export var door_id: StringName = ""

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
	
	if door_id == "":
		var root_scene := get_tree().current_scene
		var scene_path := root_scene.scene_file_path
		door_id = "%s:%s" % [scene_path, get_path()]
		
	if GameState.is_door_open(door_id):
		_is_open = true
		blocker.disabled = true
		requires_key = false

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
	
	if requires_key and not GameState.is_door_open(door_id):
		var key_used := Inventory.use_key()
		if not key_used:
			_play_locked_sound()
			return
		GameState.mark_door_open(door_id)
		requires_key = false
	
	_is_open = true
	blocker.disabled = true
	
	animation.play("open")


func close() -> void:
	if not _is_open:
		return
	if single_use:
		return
	
	_is_open = false
	blocker.disabled = false

	animation.play("close")


func _play_locked_sound() -> void:
		audio_player.stream = locked_sound
		audio_player.play()
