extends Node


var game_started := false
var input_locked = false
var game_over := false
var last_scene_path: String = ""
var last_spawn_tag: StringName = "default"
var is_respawning: bool = false
# Added by Alfred
var start_with_opening_tutorial: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
