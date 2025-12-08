class_name Slimeball
extends Area2D

@export var damage:int
@export var speed = 30
@export var fixed_sprite_rotation = false

@onready var sprite:AnimatedSprite2D = $Sprite

var _exploded = false

func _ready():
	area_entered.connect(func(a):
		if a is Health and not _exploded:
			a.take_damage(damage)
			_exploded = true
			_explode()
	)
	if fixed_sprite_rotation:
		sprite.global_rotation = 0

func _physics_process(_delta):
	if not _exploded:
		var vel = transform.x * speed
		global_position += vel * _delta


func _explode():
	_exploded = true
	sprite.play("explode")
	await sprite.animation_finished
	queue_free()
