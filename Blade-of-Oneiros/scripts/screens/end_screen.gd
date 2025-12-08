extends Node

@onready var end_video = $CanvasLayer/EndVideo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_video.visible = true
	hud.visible = false
	end_video.play()
	print("game over")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameState.game_finished:
		print("game over")
		GameState.game_finished = false
		end_video.visible = true
		hud.visible = false
		end_video.play()


func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/title_scene/title_screen.tscn")
