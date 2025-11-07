class_name MoveRightCommand
extends Command


func execute(character: Character) -> Status:
	character.velocity.x = 1.0 * character.move_speed
	character.change_facing(Character.Facing.RIGHT)
	return Status.DONE
