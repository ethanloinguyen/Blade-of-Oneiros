class_name MoveUpCommand
extends Command


func execute(character: Character) -> Status:
	character.velocity.y = -1.0 * character.move_speed
	character.change_facing(Character.Facing.UP)
	return Status.DONE
