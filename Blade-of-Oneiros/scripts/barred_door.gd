class_name BarredDoor
extends Node2D


@export var start_open: bool = false
@export var gate: AudioStream
@export var door_id: StringName = ""
@export var persistent: bool = true
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_open: bool = false


func _ready() -> void:
	if door_id == "":
		var root_scene := get_tree().current_scene
		var scene_path := root_scene.scene_file_path
		door_id = "%s:%s" % [scene_path, get_path()]
	
	if GameState.is_door_open(door_id) or start_open:
		is_open = true
		animation_player.play("open")
	else:
		is_open = false
		animation_player.play("closed")
		

func _open() -> void:
	if is_open:
		return
	is_open = true
	if persistent and door_id != "":
		GameState.mark_door_open(door_id)
	audio.stream = gate
	audio.play()
	animation_player.play("open")
	
	

func _close() -> void:

	if not is_open:
		return

	is_open = false

	audio.stream = gate
	audio.play()
	animation_player.play("closed")

	print("BarredDoor _close: id=", door_id)


func _on_triggerscene_triggered(body: Node) -> void:
	_close()
