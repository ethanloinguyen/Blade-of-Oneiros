extends Node2D

@export var amount: int = 1

@onready var sprite := $Sprite2D
@onready var area := $Area2D

func _ready():
	area.connect("body_entered", _on_body_entered)


func _on_body_entered(body):
	if body is Player:
		Inventory.add_potion(amount)
		_play_pickup_animation()


func _play_pickup_animation():
	area.monitoring = false   # disable further collisions

	var tween = create_tween()
	tween.set_parallel(true)

	# Float upward
	tween.tween_property(self, "position:y", position.y - 10, 0.5)

	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)

	# When finished, delete the whole potion scene
	tween.finished.connect(func():
		queue_free()
	)
