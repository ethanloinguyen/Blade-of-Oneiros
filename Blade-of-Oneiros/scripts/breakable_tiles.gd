class_name BreakableTiles
extends TileMapLayer

signal player_fell(tile_coords: Vector2i)

@export var source_id: int = 0

@export var reg_tile: Vector2i = Vector2i(0, 0)
@export var cracked_tile: Vector2i = Vector2i(1, 0)
@export var broken_tile: Vector2i = Vector2i(2, 0)

var step_count: Dictionary = {}
var prev_tile: Vector2i = Vector2i(999, 999)


func process_player_step(world_pos: Vector2, player: Node) -> void:
	var local_pos: Vector2 = to_local(world_pos)
	var coords: Vector2i = local_to_map(local_pos)

	if coords == prev_tile:
		return
	prev_tile = coords


	if get_cell_source_id(coords) != source_id:
		return

	var atlas: Vector2i = get_cell_atlas_coords(coords)

	if atlas == reg_tile:
		step_count[coords] = 1
		set_cell(coords, source_id, cracked_tile)

	elif atlas == cracked_tile:
		var count := int(step_count.get(coords, 1)) + 1
		step_count[coords] = count

		if count >= 2:
			set_cell(coords, source_id, broken_tile)
			step_count.erase(coords)
			_handle_tile_broken(coords, player)


func _handle_tile_broken(coords: Vector2i, player: Node) -> void:
	var tile_center_local: Vector2 = map_to_local(coords)
	var tile_center_global: Vector2 = to_global(tile_center_local)

	if "start_fall" in player:
		player.start_fall(tile_center_global)

	player_fell.emit(coords)
