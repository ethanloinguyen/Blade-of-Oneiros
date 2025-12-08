extends Node

@onready var audio = $AudioStreamPlayer2D
@export var music_audio: AudioStream
@onready var start_button = $CanvasLayer/StartButton
@onready var intro_video = $CanvasLayer/IntroVideo
@onready var background = $CanvasLayer/Background
@onready var title = $CanvasLayer/Title
@onready var animation_player = $CanvasLayer/Title/AnimationPlayer

var _video_playing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("default")
	start_button.pressed.connect(_on_start_button_pressed)
	intro_video.finished.connect(_on_video_finished)
	play_audio(music_audio)
	
	
	#Hide video until button is pressed
	intro_video.visible = false
	hud.visible = false
	GameState.game_started = false
	GameState.game_over = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_start_button_pressed():
	background.visible = false
	start_button.visible = false
	title.visible = false
	stop_audio()
	
	#Show and start video
	intro_video.visible = true
	intro_video.play()
	_video_playing = true
	
	
func _on_video_finished():
	_video_playing = false
	GameState.game_started = true
	GameState.game_over = false
	
	#Added by Alfred
	GameState.start_with_opening_tutorial = true

	var first_level := "res://scenes/level_scenes/lvl_1.tscn"
	GameState.last_scene_path = first_level
	GameState.last_spawn_tag = "default"
	PlayerManagement.change_level(first_level, "default")


	
func _input(event):
	if _video_playing and (event is InputEventKey or event is InputEventMouseButton):
		if event.is_pressed():
			get_viewport().set_input_as_handled()
			_skip_video()
			
func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()	
	
func stop_audio():
	audio.stop()
			
func _skip_video():
	intro_video.stop()
	_video_playing = false
	
	#Handle game input so it doesn't propogate to player
	GameState.input_locked = true
	await get_tree().create_timer(0.15).timeout
	GameState.input_locked  = false
	_on_video_finished()
	
