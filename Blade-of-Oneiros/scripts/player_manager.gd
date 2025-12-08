class_name PlayerManager
extends Node

const PLAYER = preload("res://scenes/swordsman.tscn")

var player: Node2D
var spawned: bool = false
var next_spawn: StringName = &"default"


func _ready() -> void:
	#player = PLAYER.instantiate()
	#player.add_to_group("player")
	#player.owner = null
	check_exist()
	get_tree().scene_changed.connect(_on_scene_changed)
	
	

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy._player = player

	_place_player()

func check_exist() -> void:
	if player == null or not is_instance_valid(player):
		player = PLAYER.instantiate()
		player.add_to_group("player")
		player.owner = null
		
		
func change_level(scene_path: String, spawn_tag: StringName = "default") -> void:
	next_spawn = spawn_tag
	GameState.last_scene_path = scene_path
	GameState.last_spawn_tag = spawn_tag
	check_exist()
	if player and is_instance_valid(player):
		var root := get_tree().root
		var parent = player.get_parent()
		if parent and parent != root:
			parent.remove_child(player)
			root.add_child(player)

		#if player.get_parent() != root:
			#player.get_parent().remove_child(player)
			#root.add_child(player)
	get_tree().call_deferred("change_scene_to_file", scene_path)
	


func _on_scene_changed() -> void:
	_place_player()


func _place_player() ->void:
	var root = get_tree().current_scene
	
	if root == null or player == null:
		return
		
	var entities := root.find_child("Entities", true, false)


	if entities != null:
		if player.get_parent() != entities:
			if player.get_parent():
				player.get_parent().remove_child(player)
			entities.add_child(player)
			
	var breakable := root.find_child("BreakableTiles", true, false)
	
	if breakable:
		player.breakable_tiles = breakable
		#print("Assigned BreakableTiles to player:", breakable)
	else:
		#print("No BreakableTiles in this scene.")
		#uncomment for debug, to check if breakable tiles is being assigned
		player.breakable_tiles = null
		
		
	var spawn = _find_spawn(root, next_spawn)
	if spawn == null:
		spawn = _find_spawn(root, "default")
	if spawn == null:
		spawn = _get_any_spawn(root)
		
	if spawn:
		# respawn players
		player.global_position = spawn.global_position
		if spawn is SpawnPoint:
			GameState.last_scene_path = root.scene_file_path
			GameState.last_spawn_tag = (spawn as SpawnPoint).tag
			
		if GameState.is_respawning and "reset_player" in player:
			player.reset_player()
			GameState.is_respawning = false
			
		var cam := player.get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.snap_to_player()

	# reinstantiate enemy container
	#if entities != null:
		#var enemy_container:EnemyContainer = entities.find_child("Enemies")
		#if enemy_container != null:
			#enemy_container.update_spawn_pos_dict()
			#var enemy_spawn_pos = enemy_container.enemy_spawn_pos
			#var container_path = enemy_container.scene_file_path
			#enemy_container.queue_free()
			#var new_enemy_container:EnemyContainer = load(container_path).instantiate()
			#new_enemy_container.enemy_spawn_pos = enemy_spawn_pos
			#entities.add_child(new_enemy_container)
			#new_enemy_container.update_spawn_pos_dict()
	# reinstantiate enemy container
	if entities != null:
		var enemy_container := entities.find_child("Enemies") as EnemyContainer
		if enemy_container == null:
			# Either there's no "Enemies" node or it doesn't have EnemyContainer script
			return

		enemy_container.update_spawn_pos_dict()
		var enemy_spawn_pos = enemy_container.enemy_spawn_pos
		var container_path = enemy_container.scene_file_path

		enemy_container.queue_free()

		var new_enemy_container := load(container_path).instantiate() as EnemyContainer
		if new_enemy_container == null:
			return

		new_enemy_container.enemy_spawn_pos = enemy_spawn_pos
		entities.add_child(new_enemy_container)
		new_enemy_container.update_spawn_pos_dict()



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
	
