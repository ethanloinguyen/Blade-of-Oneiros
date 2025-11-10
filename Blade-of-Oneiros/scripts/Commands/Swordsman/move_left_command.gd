class_name MoveLeftCommand
extends Command


func execute(character: Character) -> Status:
	if character.running:
		character.velocity.x -= character.run_speed
	else:
		character.velocity.x -= character.move_speed
	
	character.change_facing(Character.Facing.LEFT)
	#character.play_animation("walk")
	return Status.DONE
