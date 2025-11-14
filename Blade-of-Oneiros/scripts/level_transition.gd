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
	
	
func _on_enter(body: Node) -> void:
	if not _enabled:
		return
	if not body.is_in_group("player"):
		return
	_player_inside = true
	if not press_to_use:
		_trigger()
		
func _trigger() -> void:
	if single_use:
		_enabled = false
	PlayerManagement.change_level(target_scene, target_spawn)
