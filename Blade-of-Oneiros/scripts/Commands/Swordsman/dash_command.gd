class_name DashCommand
extends Command 

func execute(character: Character) -> Status:
	if character.dashing:
		return Status.DONE
<<<<<<< Updated upstream
		
	character.dashing = true
	character.velocity = character.facing_direction * character.dash_speed
=======
	
	var dash_direction: Vector2 = character.direction
	
	if dash_direction == Vector2.ZERO:
		dash_direction = character.facing_direction
	else:
		dash_direction = dash_direction.normalized()
	
	character.dashing = true
	character.dash_on_cooldown = true
	character.velocity = dash_direction * character.dash_speed
>>>>>>> Stashed changes
	character.dash_timer = character.dash_duration
	character.dash_cooldown_timer = character.dash_cooldown
	
	return Status.DONE
