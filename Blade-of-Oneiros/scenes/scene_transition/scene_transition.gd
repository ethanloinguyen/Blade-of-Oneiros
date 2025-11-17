extends CanvasLayer

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer
@onready var fade_player: AudioStreamPlayer = $Control/fadePlayer

func fade_out() -> bool:
	animation_player.play("fade out")
	fade_player.play()
	await animation_player.animation_finished
	return true


func fade_in() -> bool:
	animation_player.play("fade in")
	await animation_player.animation_finished
	return true
	
