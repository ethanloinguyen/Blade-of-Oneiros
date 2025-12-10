extends Node


var game_started := false
var input_locked = false
var game_over := false
var last_scene_path: String = ""
var last_spawn_tag: StringName = "default"
var is_respawning: bool = false
var has_armor: bool = false
var game_finished := false

var collected: Dictionary = {}
var opened_doors: Dictionary ={}
# Added by Alfred
var start_with_opening_tutorial: bool = false


func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	if game_finished:
		game_finished = false
		get_tree().change_scene_to_file("res://scenes/endscreen/end_screen.tscn")


func mark_pickup_collected(id: StringName) -> void:
	collected[id] = true


func is_pickup_collected(id: StringName) -> bool:
	return collected.get(id, false)


func mark_door_open(id: StringName) -> void:
	if id == "":
		return
	opened_doors[id] = true
	
	
func is_door_open(id: StringName) -> bool:
	if id == "":
		return false
	return opened_doors.get(id, false)
