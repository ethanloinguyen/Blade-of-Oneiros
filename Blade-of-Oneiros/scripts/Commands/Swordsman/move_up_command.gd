class_name MoveUpCommand
extends Command


func execute(character: Character) -> Status:
	if character.running:
		character.velocity.y -= character.run_speed
	else:
		character.velocity.y -= character.move_speed
		
	character.change_facing(Character.Facing.UP)
	#character.play_animation("walk")
	return Status.DONE
