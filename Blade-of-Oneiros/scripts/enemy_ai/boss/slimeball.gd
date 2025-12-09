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
			_explode()
	)
	body_entered.connect(func(b):
		# check collided body is not player or enemy
		if not (b is CollisionObject2D and b.collision_layer & (0b11 << 1) != 0):
			_explode()
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
