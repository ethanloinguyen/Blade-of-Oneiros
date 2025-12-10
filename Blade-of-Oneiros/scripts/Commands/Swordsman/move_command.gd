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
	
	# Only consume stamina when actually moving
	if Input.is_action_pressed("run"):
		if StaminaSystem.try_use(character.run_cost):
			character.running = true
	else:
		character.running = false
	
	if character.running:
		character.velocity += character.direction * character.move_speed * character.run_factor
	else:
		character.velocity += character.direction * character.move_speed
	
	return Status.DONE
