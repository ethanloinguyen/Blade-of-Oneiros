class_name MoveLeftCommand
extends Command


func execute(character: Character) -> Status:
	character.velocity.x -= character.move_speed
	character.change_facing(Character.Facing.LEFT)
	#character.play_animation("walk")
	return Status.DONE
