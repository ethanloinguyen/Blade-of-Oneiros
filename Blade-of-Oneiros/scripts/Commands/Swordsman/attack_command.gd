class_name AttackCommand
extends Command 


func execute(character: Character) -> Status:
	if character.attacking:
		return Status.DONE
	
	character.hitbox_collision.disabled = false
	character.attacking = true
	character.attack_timer = character.attack_duration
	character.velocity = Vector2.ZERO
	
	return Status.DONE
