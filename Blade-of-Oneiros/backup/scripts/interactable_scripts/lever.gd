class_name Lever
extends StaticBody2D

signal activated
signal deactivated

@export var default_state: bool = false
@export var action: StringName = &"interact"
@export var target_group: StringName = &"lever_target"
@export var cooldown: float = 1.0

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $Area2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_on: AudioStream = preload("res://assets/audio/plate1.wav")
@onready var audio_off: AudioStream = preload("res://assets/audio/plate2.wav")


var is_on: bool
var _player_near: bool = false
var _cooldown_timer: float = 0.0


func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

	set_process(true)
	set_process_unhandled_input(true)

	is_on = default_state


func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_near = true
	

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_near = false
	

func _unhandled_input(event: InputEvent) -> void:
	if not _player_near:
		return
	if _cooldown_timer > 0.0:
		return
	if event.is_action_pressed(action):
		_toggle()


func _toggle() -> void:
	is_on = not is_on
	_cooldown_timer = cooldown

	if is_on:
		animation.play("on")
		play_audio(audio_on)
		activated.emit()
	else:
		animation.play("off")
		play_audio(audio_off)
		deactivated.emit()


func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
