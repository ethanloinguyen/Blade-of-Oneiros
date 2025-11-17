class_name LevelTransition
extends Area2D


@export_file("*.tcsn") var target_scene: String
@export var target_spawn: StringName = &"default"
@export var press_to_use: bool = false
@export var action: StringName = &"interact"
@export var single_use: bool = false

var _player_inside :bool = false
var _enabled :bool = true


func _ready() -> void:
	body_entered.connect(_on_enter)
	set_process_unhandled_input(true)
	
func _on_enter(body: Node) -> void:
	#for debug purposes
	#print("Door", name, "body_entered by:", body.name, "groups:", body.get_groups())
	if not _enabled:
		return
	if not body.is_in_group("player"):
		return
	_player_inside = true
	if not press_to_use:
		_trigger()
	

func _unhandled_input(event: InputEvent) -> void:
	
	if not _enabled or not press_to_use or not _player_inside:
		return
	if event.is_action_pressed(action):
		_trigger()
	
	
func _trigger() -> void:
	#for debug
	#print("Door", name, "TRIGGER: target_scene =", target_scene, "target_spawn =", target_spawn)
	await SceneTransition.fade_out()
	if single_use:
		_enabled = false
	PlayerManagement.change_level(target_scene, target_spawn)
	await SceneTransition.fade_in()
