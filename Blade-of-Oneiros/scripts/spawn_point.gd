class_name SpawnPoint
extends Marker2D

@export var tag: StringName = &"default"

func _ready() -> void:
	add_to_group("spawn_point")
