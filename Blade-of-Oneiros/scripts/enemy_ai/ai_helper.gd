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
