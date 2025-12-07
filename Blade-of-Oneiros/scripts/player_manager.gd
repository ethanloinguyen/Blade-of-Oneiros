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
	
	

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy._player = player

	call_deferred("_place_player")


func change_level(scene_path: String, spawn_tag: StringName = "default") -> void:
	next_spawn = spawn_tag
	if player and is_instance_valid(player):
		var root := get_tree().root
		if player.get_parent() != root:
			player.get_parent().remove_child(player)
			root.add_child(player)
	get_tree().call_deferred("change_scene_to_file", scene_path)
	


func _on_scene_changed() -> void:
	call_deferred("_place_player")


func _place_player() ->void:
	var root = get_tree().current_scene
	
	if root == null or player == null:
		return
	var entities := root.get_node_or_null("Entities")
	if entities and player.get_parent() != entities:
		player.get_parent().remove_child(player)
		entities.add_child(player)
		
		
	var spawn = _find_spawn(root, next_spawn)
	if spawn == null:
		spawn = _find_spawn(root, "default")
	if spawn == null:
		spawn = _get_any_spawn(root)
		
	if spawn:
		player.global_position = spawn.global_position
		var cam := player.get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.snap_to_player()
	
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
	
