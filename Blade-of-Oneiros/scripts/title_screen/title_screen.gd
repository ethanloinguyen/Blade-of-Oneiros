extends Node

@onready var start_button = $CanvasLayer/StartButton
@onready var intro_video = $CanvasLayer/IntroVideo
@onready var background = $CanvasLayer/Background


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	intro_video.finished.connect(_on_video_finished)
	
	#Hide video until button is pressed
	intro_video.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_start_button_pressed():
	background.visible = false
	start_button.visible = false
	
	#Show and start video
	intro_video.visible = true
	intro_video.play()
	
func _on_video_finished():
	GameState.game_started = true
	get_tree().change_scene_to_file("res://scenes/level_scenes/lvl_1.tscn")
	
	
	

		
