class_name JumpState
extends State

var ENEMY_COLLISION_LAYER = 2 << 1

var _enemy
var _sprite

var _target_rel:Vector2
var _time:float

func _init(enemy, jump_height:float, jump_duration:float, sprite:Node2D, attack_hitbox:Hitbox, exit_jump:Callable):
	_enemy = enemy
	_sprite = sprite
	super(
		"Jump",
		func():
		_time = 0.0
		enemy.collision_layer &= ~(ENEMY_COLLISION_LAYER)

		await _enemy.get_tree().create_timer(jump_duration).timeout
		exit_jump.call()
		,
		func(delta):
		_time += delta
		var t = clamp(_time / jump_duration, 0.0, 1.0)
		var base_offset = _target_rel / jump_duration
		enemy.position += base_offset * delta
		var y_pos = -4.0 * jump_height * t * (1.0 - t)
		sprite.position = Vector2(0.0, y_pos)
		,
		func():
		sprite.position = Vector2.ZERO
		attack_hitbox.activate(Vector2.UP, false)
		enemy.collision_layer |= ENEMY_COLLISION_LAYER
	)


func jump(target:Vector2):
	_target_rel = target - _sprite.global_position
	_enemy.fsm.change_state(self)
