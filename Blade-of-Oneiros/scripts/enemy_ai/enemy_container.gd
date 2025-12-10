class_name EnemyContainer
extends Node2D


@export var persistance: bool = true
var enemy_spawn_pos:Dictionary[NodePath, Vector2]
var enemy_ids: Dictionary[NodePath, StringName] = {}

func _ready() -> void:
	update_spawn_pos_dict()

func update_spawn_pos_dict():
	var root_scene := get_tree().current_scene
	var scene_path := root_scene.scene_file_path

	for enemy:Node2D in get_children():
		# handle positions
		var path: NodePath = get_path_to(enemy)
		if path not in enemy_spawn_pos:
			enemy_spawn_pos[path] = enemy.global_position
		else:
			enemy.global_position = enemy_spawn_pos[path]

		# handle persistence
		if not persistance:
			continue
		var enemy_id: StringName = "%s:%s" % [scene_path, path]
		enemy_ids[path] = enemy_id

		if GameState.is_enemy_dead(enemy_id):
			enemy.queue_free()
			continue
			
		if enemy.has_node("Health"):
			var health = enemy.get_node("Health")
			if health.has_signal("died"):
				var callable:= Callable(self, "_on_enemy_died").bind(path)
				if not health.died.is_connected(callable):
					health.died.connect(callable)

func _on_enemy_died(path: NodePath) -> void:
	if not persistance:
		return
	var enemy_id: StringName = enemy_ids.get(path, "")
	if enemy_id != "":
		GameState.mark_enemy_dead(enemy_id)
