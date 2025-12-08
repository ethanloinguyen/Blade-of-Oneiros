class_name DashCommand
extends Command 

func execute(character: Character) -> Status:
	if character.dashing:
		return Status.DONE
	
	var dash_direction: Vector2 = character.direction
	
	if dash_direction == Vector2.ZERO:
		dash_direction = character.facing_direction
	else:
		dash_direction = dash_direction.normalized()
		
	character.dashing = true
	character.dash_on_cooldown = true
	character.dash_direction = dash_direction	
	character.dash_timer = character.dash_duration
	character.dash_cooldown_timer = character.dash_cooldown
	character.dash_invuln_timer = character.dash_invuln_duration
	character.health.set_invincible(true)
	
	return Status.DONE
