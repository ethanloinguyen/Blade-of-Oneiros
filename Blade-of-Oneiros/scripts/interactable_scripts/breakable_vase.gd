class_name BreakableVase
extends StaticBody2D

@export var potion_scene: PackedScene
@export var hit_sound: AudioStream      
@export var break_sound: AudioStream   
@export var animation_name: StringName = "break"

@export var shake_amount: float = 2.0
@export var shake_duration: float = 0.12
@export var persistent: bool = true
@export var pickup_id: StringName = "" 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health: Node = $Health
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _broken: bool = false
var _shake_tween: Tween


func _ready() -> void:
	if persistent:
		if pickup_id == "":
			var root_scene := get_tree().current_scene
			var scene_path := root_scene.scene_file_path
			pickup_id = "%s:%s" % [scene_path, get_path()]
		
		if GameState.is_pickup_collected(pickup_id):
			queue_free()
			return
			
	if sprite.sprite_frames:
		if sprite.sprite_frames.has_animation(animation_name):
			sprite.animation = animation_name
		else:
			animation_name = sprite.animation 
		
		sprite.stop()
		sprite.frame = 0  

	if health.has_signal("hurt"):
		health.hurt.connect(_on_health_hurt)


func _on_health_hurt() -> void:
	if _broken:
		return

	var f := sprite.frame

	match f:
		0:
			_play_hit_feedback()
			sprite.frame = 1
		1:
			_play_hit_feedback()
			_start_break_animation()
		_:
			return


func _play_hit_feedback() -> void:
	if hit_sound:
		audio.stream = hit_sound
		audio.play()


	if _shake_tween:
		_shake_tween.kill()

	var original_pos: Vector2 = sprite.position
	_shake_tween = create_tween()
	_shake_tween.set_trans(Tween.TRANS_SINE)
	_shake_tween.set_ease(Tween.EASE_OUT)

	var step := shake_duration / 3.0
	_shake_tween.tween_property(sprite, "position", original_pos + Vector2(shake_amount, 0.0), step)
	_shake_tween.tween_property(sprite, "position", original_pos - Vector2(shake_amount, 0.0), step)
	_shake_tween.tween_property(sprite, "position", original_pos, step)


func _start_break_animation() -> void:
	if _broken:
		return
	_broken = true

	if is_instance_valid(collision_shape):
		collision_shape.disabled = true

	audio.stream = break_sound
	audio.play()

	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.animation = animation_name
		sprite.play()
		sprite.frame = 2  
		sprite.animation_finished.connect(_on_break_anim_finished, CONNECT_ONE_SHOT)


func _on_break_anim_finished() -> void:
	if persistent and pickup_id != "":
		GameState.mark_pickup_collected(pickup_id)
	_spawn_potion()
	queue_free()


func _spawn_potion() -> void:
	if potion_scene == null:
		return

	var potion := potion_scene.instantiate()
	get_parent().add_child(potion)
	potion.global_position = global_position
