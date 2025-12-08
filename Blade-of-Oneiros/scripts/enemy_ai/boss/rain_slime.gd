class_name RainSlime
extends Area2D

@export var height:float
@export var fall_duration:float
@export var damage:int
@export var remain_duration:float

@onready var sprite:AnimatedSprite2D = $Sprite

func _ready():
	# fall to floor
	sprite.position.y = -height
	while sprite.position.y < 0:
		await get_tree().process_frame
		if not is_instance_valid(self):
			return

	# splat on floor and become puddle
	sprite.play("splat")
	await sprite.animation_finished
	if not is_instance_valid(self):
		return
	sprite.play("puddle")
	area_entered.connect(func(a):
		if a is Health:
			a.take_damage(damage)
			queue_free()
	)
	# despawn after remain duration
	await get_tree().create_timer(remain_duration).timeout
	if not is_instance_valid(self):
		return
	queue_free()


func _process(_delta):
	# make sprite fall down
	sprite.position.y = min(sprite.position.y + height/fall_duration * _delta, 0.0)
