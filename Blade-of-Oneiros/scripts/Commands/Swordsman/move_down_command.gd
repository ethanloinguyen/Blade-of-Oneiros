class_name MoveDownCommand
extends Command


func execute(character: Character) -> Status:
	if character.running:
		character.velocity.y += character.run_speed
	else:
		character.velocity.y += character.move_speed
	
	character.change_facing(Character.Facing.DOWN)
	#character.play_animation("walk")
	return Status.DONE
