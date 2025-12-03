class_name DirectionSnap
extends Node


#Function to force box to move in cardinal direction/avoids diagonal conflicts
static func _snap_to_cardinal(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return Vector2.ZERO

	var cardinals: Array[Vector2] = [
		Vector2.RIGHT,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.UP,
	]

	var best_direction: Vector2 = Vector2.ZERO
	var best_alignment: float = -1.0

	for c in cardinals:
		var alignment: float = dir.dot(c)
		if alignment > best_alignment:
			best_alignment = alignment
			best_direction = c

	return best_direction
