class_name IdleRightCommand
extends Command

func execute(character: Character) -> Status:
	character.velocity.x = 0
	character.velocity.y = 0
	return Status.DONE
