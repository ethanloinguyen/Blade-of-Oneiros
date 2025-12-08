class_name PlayerManager
extends Node

const PLAYER = preload("res://scenes/swordsman.tscn")

var player: Node2D
var spawned: bool = false
var next_spawn: StringName = &"default"


func _ready() -> void:
	player = PLAYER.instantiate()
	player.add_to_group("player")
	get_tree().root.call_deferred("add_child",player)
	player.owner = null
	get_tree().scene_changed.connect(_on_scene_changed)
	
<<<<<<< Updated upstream
	call_deferred("_place_player")
	
=======
	# ADDED BY ALFRED: register player as "swordsman" character with the DialogueOrchestrator
	DialogueOrchestrator.register_character("swordsman", player)


	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy._player = player

	_place_player()

func check_exist() -> void:
	if player == null or not is_instance_valid(player):
		player = PLAYER.instantiate()
		player.add_to_group("player")
		player.owner = null
		
		
>>>>>>> Stashed changes
func change_level(scene_path: String, spawn_tag: StringName = "default") -> void:
	next_spawn = spawn_tag
	get_tree().call_deferred("change_scene_to_file", scene_path)
	


func _on_scene_changed() -> void:
<<<<<<< Updated upstream
	call_deferred("_place_player")
=======
	_place_player()
	
	#ADded by Alfred
	if GameState.start_with_opening_tutorial \
	and GameState.last_scene_path == "res://scenes/level_scenes/lvl_1.tscn":
		GameState.start_with_opening_tutorial = false
		DialogueOrchestrator.start("tutorial_cutscene")

>>>>>>> Stashed changes


func _place_player() ->void:
	var root = get_tree().current_scene
	
	if root == null or player == null:
		return
	
	var spawn = _find_spawn(root, next_spawn)
	if spawn == null:
		spawn = _find_spawn(root, "default")
	if spawn == null:
		spawn = _get_any_spawn(root)
		
	if spawn:
		player.global_position = spawn.global_position
		
	
func _find_spawn(root: Node, tag: StringName) -> Node2D:
	for n in get_tree().get_nodes_in_group("spawn_point"):
		if root.is_ancestor_of(n) and (n as SpawnPoint).tag == tag:
			return n
	return null


func _get_any_spawn(root: Node) -> Node2D:
	for n in get_tree().get_nodes_in_group("spawn_point"):
		if root.is_ancestor_of(n):
			return n
	return null
	
