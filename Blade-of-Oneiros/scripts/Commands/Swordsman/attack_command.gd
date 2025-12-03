class_name AttackCommand
extends Command 


func execute(character: Character) -> Status:
	if character.attacking:
		return Status.DONE
		
	character.attacking = true
	character.velocity = Vector2.ZERO
	
	return Status.DONE
