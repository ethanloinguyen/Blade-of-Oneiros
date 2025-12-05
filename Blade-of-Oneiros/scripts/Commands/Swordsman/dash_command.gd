class_name DashCommand
extends Command 

func execute(character: Character) -> Status:
	if character.dashing:
		return Status.DONE
	
	var dash_direction: Vector2 = character.direction
	character.dashing = true
	dash_direction = dash_direction.normalized()
	character.velocity = dash_direction * character.dash_speed
	character.dash_timer = character.dash_duration
	
	return Status.DONE
