class_name DashCommand
extends Command 

func execute(character: Character) -> Status:
	if character.dashing:
		return Status.DONE
		
	character.dashing = true
	character.velocity = character.facing_direction * character.dash_speed
	character.dash_timer = character.dash_duration
	
	return Status.DONE
