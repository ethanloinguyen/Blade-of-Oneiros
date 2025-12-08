extends Node

var game_started := false
var input_locked = false
var game_over := false
var last_scene_path: String = ""
var last_spawn_tag: StringName = "default"
var is_respawning: bool = false
