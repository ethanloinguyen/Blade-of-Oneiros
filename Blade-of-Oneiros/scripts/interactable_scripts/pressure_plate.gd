class_name PressurePlate
extends Node2D


signal activated
signal deactivated

var bodies: int = 0
var is_active: bool = false
var off_rect: Rect2


@onready var area_2d: Area2D = $Area2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_activate: AudioStream = preload("res://assets/audio/plate1.wav")
@onready var audio_deactivate: AudioStream = preload("res://assets/audio/plate2.wav")
@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite2: Sprite2D = $Sprite2D2

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	sprite.visible = true
	sprite2.visible = false
	
func _on_body_entered(_b : Node2D) -> void:
	bodies += 1
	_is_activated()
	pass
	
	
func _on_body_exited(_b : Node2D) -> void:
	bodies -= 1
	_is_activated()
	pass


func _is_activated() -> void:
	if bodies > 0 and is_active == false:
		is_active = true

		sprite.visible = false
		sprite2.visible = true
		play_audio(audio_activate)
		activated.emit()
	elif bodies == 0 and is_active == true:
		is_active = false
	
		sprite.visible = true
		sprite2.visible = false
		play_audio(audio_deactivate)
		deactivated.emit()
		
	
func play_audio(_stream : AudioStream) -> void:
	if not is_inside_tree():
		return
	if audio == null or not audio.is_inside_tree():
		return
	audio.stream = _stream
	audio.play()
