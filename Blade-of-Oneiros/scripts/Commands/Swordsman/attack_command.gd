class_name AttackCommand
extends Command 


func execute(character: Character) -> Status:
	if character.attacking:
		return Status.DONE

	character.attacking = true
	character.attack_timer = character.attack_duration
	character.velocity = Vector2.ZERO
	character.hitbox.activate(character.facing_direction, true, true)

	return Status.DONE
