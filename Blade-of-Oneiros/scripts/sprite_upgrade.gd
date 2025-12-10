extends Node2D

@onready var area := $Area2D

func _ready():
	area.connect("body_entered", _on_body_entered)


func _on_body_entered(body):
	if body is Player:
		body.upgrade_sprite()
		GameState.has_armor = true
		queue_free()
