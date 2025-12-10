class_name EnemyContainer
extends Node2D


@export var persistance: bool = true
var enemy_spawn_pos:Dictionary[NodePath, Vector2]
var enemy_ids: Dictionary[NodePath, StringName] = {}


func _ready() -> void:
	update_spawn_pos_dict()
	
	
func update_spawn_pos_dict():
	if persistance == true:
		
		var root_scene := get_tree().current_scene
		var scene_path := root_scene.scene_file_path

		for enemy:Node2D in get_children():
			var path: NodePath = get_path_to(enemy)
			
			var enemy_id: StringName = "%s:%s" % [scene_path, path]
			enemy_ids[path] = enemy_id
			
			if GameState.is_enemy_dead(enemy_id):
				enemy.queue_free()
				continue

			if path not in enemy_spawn_pos:
				enemy_spawn_pos[path] = enemy.global_position
			else:
				enemy.global_position = enemy_spawn_pos[path]
			if enemy.has_node("Health"):
				var health = enemy.get_node("Health")
				if health.has_signal("died"):
					health.died.connect(_on_enemy_died.bind(path))
	else:
		for enemy:Node2D in get_children():
			var path: NodePath = get_path_to(enemy)
			if path not in enemy_spawn_pos:
				enemy_spawn_pos[path] = enemy.global_position
			else:
				enemy.global_position = enemy_spawn_pos[path]
			


func _on_enemy_died(path: NodePath) -> void:
	var enemy_id: StringName = enemy_ids.get(path, "")
