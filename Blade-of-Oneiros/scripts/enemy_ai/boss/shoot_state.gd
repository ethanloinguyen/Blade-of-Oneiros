class_name ShootState
extends State

var _enemy

var _center_pos:Vector2

func _init(enemy, projectile:PackedScene, num_dirs: float, offset:bool, exit_shoot:Callable):
	_enemy = enemy

	# create shoot dirs
	var shoot_dirs = []
	var interval = TAU / num_dirs
	for i in range(num_dirs):
		var a = i * interval
		if offset:
			a += interval/2
		var dir = Vector2(cos(a), sin(a)).normalized()
		shoot_dirs.push_back(dir)

	super(
	"Shoot",
	func():
		for dir in shoot_dirs:
			var p = projectile.instantiate()
			p.look_at(_center_pos + dir)
		exit_shoot.call()
	,
	Callable()
	,
	Callable()
	)

func shoot(center_pos:Vector2):
	_center_pos = center_pos
	_enemy.fsm.change_state(self)
