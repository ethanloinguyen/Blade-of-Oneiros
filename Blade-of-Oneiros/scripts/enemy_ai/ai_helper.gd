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
	sprite.play("%s_%s" % [animation, dir])

static func connect_to_boss_health_bar(tree:SceneTree, health:Health, over_texture:Texture2D):
	var hud:HUD = tree.get_first_node_in_group("hud")
	hud.boss_health.texture_over = over_texture
	hud.boss_health.visible = true
	hud.boss_health.max_value = health.max_health
	hud.boss_health.value = health.current_health
	health.hurt.connect(func(): hud.boss_health.value = health.current_health)
	health.died.connect(func(): hud.boss_health.visible = false)
