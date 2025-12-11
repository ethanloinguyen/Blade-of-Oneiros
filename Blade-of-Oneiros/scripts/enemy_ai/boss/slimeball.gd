class_name Slimeball
extends Area2D

@export var damage:int
@export var speed = 30
@export var fixed_sprite_rotation = false
@export var explode_audio: AudioStream

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var audio = $AudioStreamPlayer2D


var _exploded = false

func _ready():
	area_entered.connect(func(a):
		if a is Health and not _exploded:
			a.take_damage(damage)
			_explode()
	)
	body_entered.connect(func(b):
		# check collided body is not player or enemy
		if not (b is CollisionObject2D and b.collision_layer & (0b11 << 1) != 0):
			_explode()
	)
	
	sprite.frame_changed.connect(func():
		if sprite.animation.begins_with("explode") and sprite.frame == 1:
			play_audio(explode_audio)

	)


func _physics_process(_delta):
	if fixed_sprite_rotation:
		sprite.global_rotation = 0
	if not _exploded:
		var vel = transform.x * speed
		global_position += vel * _delta


func _explode():
	_exploded = true
	sprite.play("explode")
	await sprite.animation_finished
	queue_free()
	
	
func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
