extends Node

@onready var start_button = $CanvasLayer/StartButton
@onready var intro_video = $CanvasLayer/IntroVideo
@onready var background = $CanvasLayer/Background

var _video_playing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	intro_video.finished.connect(_on_video_finished)
	
	#Hide video until button is pressed
	intro_video.visible = false
	hud.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_start_button_pressed():
	background.visible = false
	start_button.visible = false
	
	#Show and start video
	intro_video.visible = true
	intro_video.play()
	_video_playing = true
	
func _on_video_finished():
	GameState.game_started = true
	get_tree().change_scene_to_file("res://scenes/level_scenes/lvl_1.tscn")
	
func _input(event):
	if _video_playing and (event is InputEventKey or event is InputEventMouseButton):
		if event.is_pressed():
			get_viewport().set_input_as_handled()
			_skip_video()
			
func _skip_video():
	intro_video.stop()
	_video_playing = false
	
	#Handle game input so it doesn't propogate to player
	GameState.input_locked = true
	await get_tree().create_timer(0.15).timeout
	GameState.input_locked  = false
	_on_video_finished()
	
