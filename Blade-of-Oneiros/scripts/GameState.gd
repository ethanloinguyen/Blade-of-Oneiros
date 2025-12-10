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
var dead_enemies: Dictionary = {}
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
	
	
func mark_enemy_dead(id: StringName) -> void:
	if id == "":
		return
	dead_enemies[id] = true


func is_enemy_dead(id: StringName) -> bool:
	if id == "":
		return false
	return dead_enemies.get(id, false)


func reset_game() -> void:
	game_started = false
	input_locked = false
	game_over = false
	game_finished = false
	is_respawning = false
	has_armor = false
	last_scene_path = ""
	last_spawn_tag = "default"
	start_with_opening_tutorial = true
	collected.clear()
	opened_doors.clear()
	dead_enemies.clear()
	Inventory.reset()
