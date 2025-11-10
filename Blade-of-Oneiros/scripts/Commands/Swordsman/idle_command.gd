class_name IdleCommand
extends Command

func execute(character: Character) -> Status:
	character.velocity.x = 0
	character.velocity.y = 0
	character.play_animation("idle")
	return Status.DONE
