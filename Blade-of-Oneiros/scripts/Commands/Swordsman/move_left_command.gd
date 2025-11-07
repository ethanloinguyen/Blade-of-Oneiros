class_name MoveLeftCommand
extends Command


func execute(character: Character) -> Status:
	character.velocity.x = -1.0 * character.move_speed
	character.change_facing(Character.Facing.LEFT)
	return Status.DONE
