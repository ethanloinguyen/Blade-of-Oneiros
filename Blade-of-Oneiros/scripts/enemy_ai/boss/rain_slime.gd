class_name RainSlime
extends Area2D

@export var height:float
@export var fall_duration:float
@export var damage:int
@export var damage_radius:float
@export var remain_duration:float
@export var splat_audio: AudioStream

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready():
	var tree = get_tree()
	sprite.position.y = -height
	
	sprite.frame_changed.connect(func():
		if sprite.animation.begins_with("splat") and sprite.frame == 3:
			play_audio(splat_audio)
	)
	
	while sprite.position.y < 0:
		if not is_instance_valid(self) or not is_inside_tree():
			return

		if tree != null:
			await tree.process_frame
		else:
			return


	if tree == null:
		return
	var player:Player = tree.get_first_node_in_group("player")
	if player == null:
		return
	if player.global_position.distance_to(global_position) <= damage_radius:
		player.health.take_damage(damage)
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
	await get_tree().create_timer(remain_duration, false).timeout
	if not is_instance_valid(self):
		return
	queue_free()


func _process(_delta):
	# make sprite fall down
	sprite.position.y = min(sprite.position.y + height/fall_duration * _delta, 0.0)


func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
