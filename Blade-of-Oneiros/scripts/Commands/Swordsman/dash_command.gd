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
	character.velocity = dash_direction * character.dash_speed	
	character.dash_timer = character.dash_duration
	character.dash_speed_factor = 1.8

	var tween := character.create_tween()
	tween.tween_property(
		character,
		"dash_speed_factor",
		0.4,                          
		character.dash_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return Status.DONE
