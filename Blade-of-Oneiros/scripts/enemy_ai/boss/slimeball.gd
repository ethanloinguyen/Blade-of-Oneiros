class_name Slimeball
extends Area2D

@export var damage:int
@export var speed = 30

func _ready():
	area_entered.connect(func(a):
		if a is Health:
			a.take_damage(damage)
			queue_free()
	)

func _physics_process(_delta):
	var vel = transform.x * speed
	global_position += vel * _delta
