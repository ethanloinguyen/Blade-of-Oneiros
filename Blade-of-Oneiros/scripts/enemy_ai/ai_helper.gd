class_name AiHelper

static func update_dir(dir:Vector2) -> String:
	var _dir = ""
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			_dir = "right"
		elif dir.x < 0:
			_dir = "left"
	else:
		if dir.y > 0:
			_dir = "down"
		elif dir.y < 0:
			_dir = "up"
	return _dir


static func play_animation(sprite:AnimatedSprite2D, animation:String, dir:String) -> void:
	var anim := "%s_%s" % [animation, dir]
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)


const MOVE_DIR_COUNT:int = 32
static func update_velocity_walk(enemy:CharacterBody2D, desired_move_dir:Vector2, move_avoid_dirs:Array[Vector2], move_avoid_collision_dist:float) -> void:
	# create move dirs array
	var move_dirs:Array[Vector2]
	var move_dirs_weights:Array[float]
	for i in range(MOVE_DIR_COUNT):
		var angle = float(i)/MOVE_DIR_COUNT * TAU
		move_dirs.push_back(Vector2(cos(angle), sin(angle)).normalized())
	move_dirs_weights.resize(MOVE_DIR_COUNT)

	# pathfind and determine velocity for walking
	if desired_move_dir.is_zero_approx():
		return
	var space_state := enemy.get_world_2d().direct_space_state
	for i in range(move_dirs.size()):
		move_dirs_weights[i] = 1
	for i in range(move_dirs.size()):
		# raycast to avoid collisions
		var query := PhysicsRayQueryParameters2D.create(enemy.global_position, enemy.global_position + move_dirs[i] * move_avoid_collision_dist)
		query.collision_mask = enemy.collision_mask
		var result:Dictionary = space_state.intersect_ray(query)
		if result:
			var dist: float = enemy.global_position.distance_to(result["position"])

			# reduce weight of all nearby rays
			for j in range(move_dirs.size()):
				var dp = move_dirs[i].dot(move_dirs[j])
				if dp > 0.3:
					var factor = dist/move_avoid_collision_dist * (1-dp)
					move_dirs_weights[j] = min(move_dirs_weights[j], factor)

		# avoid move_avoid_dirs
		for bad_dir in move_avoid_dirs:
			if move_dirs[i].dot(bad_dir) > 0.8:
				move_dirs_weights[i] = 0

		# limit dirs based on desired_move_dir
		var dir_weighted_limit = max(move_dirs[i].dot(desired_move_dir.normalized()), 0)
		if move_dirs_weights[i] > dir_weighted_limit:
			# weigh towards desired_move_dir
			move_dirs_weights[i] = dir_weighted_limit
			# prefer rightward (clockwise) movement
			var desired_dir_right = Vector2(desired_move_dir.y, -desired_move_dir.x)
			var dp = move_dirs[i].dot(desired_dir_right)
			if dp < -0.1 and move_dirs_weights[i] > 0.3:
				move_dirs_weights[i] = 0.3

	# set velocity
	var best_index = 0
	for i in range(move_dirs_weights.size()):
		if move_dirs_weights[i] > move_dirs_weights[best_index]:
			best_index = i
	enemy.velocity = move_dirs[best_index] * enemy.speed

	# reset move avoid dirs
	move_avoid_dirs.clear()


static func draw_move_dirs(enemy:CharacterBody2D, move_dirs:Array[Vector2], move_dirs_weights:Array[float], move_avoid_collision_dist:float) -> void:
	# draw movement dir weights
	if move_dirs_weights.size() == 0:
		return
	var best_index = 0
	for i in range(move_dirs_weights.size()):
		if move_dirs_weights[i] > move_dirs_weights[best_index]:
			best_index = i
	for i in range(move_dirs.size()):
		var color = Color(1, 0, 0)
		if i == best_index:
			color = Color(0, 1, 0)
		enemy.draw_line(Vector2.ZERO, move_dirs[i] * move_dirs_weights[i] * move_avoid_collision_dist, color, 1.0)



static func connect_to_boss_health_bar(tree:SceneTree, health:Health, over_texture:Texture2D):
	var hud:HUD = tree.get_first_node_in_group("hud")
	hud.boss_health.texture_over = over_texture
	hud.boss_health.visible = true
	hud.boss_health.max_value = health.max_health
	hud.boss_health.value = health.current_health
	health.hurt.connect(func(): hud.boss_health.value = health.current_health)
	health.died.connect(func(): hud.boss_health.visible = false)
