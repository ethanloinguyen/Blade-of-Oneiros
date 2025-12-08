class_name EnemyContainer
extends Node2D

var enemy_spawn_pos:Dictionary[NodePath, Vector2]

func update_spawn_pos_dict():
	for enemy:Node2D in get_children():
		var path = get_path_to(enemy)
		if path not in enemy_spawn_pos:
			enemy_spawn_pos[path] = enemy.global_position
		else:
			enemy.global_position = enemy_spawn_pos[path]
