extends Sprite2D

@export var fade_timer: float = 0.05

var time: float = 0

func _process(delta: float) -> void:
	time += delta
	var transparency := 1.0 - (time/fade_timer)
	if transparency <= 0.0:
		queue_free()
		return
	var ghost := modulate
	ghost.a = transparency
	modulate = ghost
