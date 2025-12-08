extends Node2D

@export var amount: int = 1

@onready var sprite := $Sprite2D
@onready var area := $Area2D

func _ready():
	area.connect("body_entered", _on_body_entered)
	_start_bobbing()


func _on_body_entered(body):
	if body is Player:
		Inventory.add_potion(amount)
		_play_pickup_animation()


func _start_bobbing():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var original_y = sprite.position.y

	# Animate down
	tween.tween_property(sprite, "position:y", original_y + 3, 1.5)
	
	# Animate up (loop)
	tween.tween_property(sprite, "position:y", original_y - 3, 1.5)
	
	# Loop forever
	tween.set_loops()


func _play_pickup_animation():
	area.set_deferred("monitoring", false)# disable further collisions
	
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
