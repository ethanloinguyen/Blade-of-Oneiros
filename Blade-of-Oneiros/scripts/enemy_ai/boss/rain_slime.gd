class_name RainSlime
extends Area2D

@export var height:float
@export var fall_duration:float
@export var damage:int
@export var damage_radius:float
@export var remain_duration:float

@onready var sprite:AnimatedSprite2D = $Sprite

func _ready():
	# fall to floor
	sprite.position.y = -height
	while sprite.position.y < 0:
		await get_tree().process_frame
		if not is_instance_valid(self):
			return

	# hurt player
	var player:Player = get_tree().get_first_node_in_group("player")
	if player.global_position.distance_to(global_position) <= damage_radius:
		player.health.take_damage(damage)
		print("hit")
		queue_free()
	else: area_entered.connect(func(a):
		if a is Health:
			a.take_damage(damage)
			queue_free()
	)

	# splat on floor and become puddle
	sprite.play("splat")
	$Shadow.queue_free()
	await sprite.animation_finished
	if not is_instance_valid(self):
		return
	sprite.play("puddle")

	# despawn after remain duration
	await get_tree().create_timer(remain_duration).timeout
	if not is_instance_valid(self):
		return
	queue_free()


func _process(_delta):
	# make sprite fall down
	sprite.position.y = min(sprite.position.y + height/fall_duration * _delta, 0.0)
