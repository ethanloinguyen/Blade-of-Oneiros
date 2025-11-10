class_name AttackCommand
extends Command 


func execute(character: Character) -> Status:
	if character.attacking:
		return Status.DONE
		
	character.attacking = true
	character.velocity = Vector2.ZERO
	character.play_animation("attack")
	
	await character.anim_sprite.animation_finished
	character.attacking = false
	character.play_animation("idle")
	
	return Status.DONE
