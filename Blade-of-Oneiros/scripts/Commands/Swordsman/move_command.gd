class_name MoveCommand
extends Command


func execute(character: Character) -> Status:
	if Input.is_action_pressed("ui_up"):
		character.change_facing(Character.Facing.UP)
	if Input.is_action_pressed("ui_down"):
		character.change_facing(Character.Facing.DOWN)
	if Input.is_action_pressed("ui_left"):
		character.change_facing(Character.Facing.LEFT)
	if Input.is_action_pressed("ui_right"):
		character.change_facing(Character.Facing.RIGHT)
	
	if character.running:
		character.velocity += character.direction * character.run_speed
		#character.velocity.x += character.direction.x * character.run_speed
		#character.velocity.y += character.direction.y * character.run_speed
	else:
		character.velocity += character.direction * character.move_speed
		#character.velocity.x += character.direction.x * character.move_speed
		#character.velocity.y += character.direction.y * character.move_speed
	
	return Status.DONE
