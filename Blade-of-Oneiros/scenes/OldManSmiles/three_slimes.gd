extends CharacterBody2D  

@export var character_id: String = "threeslimes"
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Start invisible
	var start_mod := modulate
	start_mod.a = 0.0
	modulate = start_mod
	visible = true

	# Register with orchestrator
	var orch := get_node_or_null("/root/DialogueOrchestrator")
	if orch:
		orch.register_character(character_id, self)


func appear_from_dialogue(duration: float) -> Tween:
	# Fade from 0 -> 1 alpha
	var start := modulate
	start.a = 0.0
	modulate = start
	visible = true

	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, duration)
	return tween

func disappear_from_dialogue(duration: float) -> Tween:
	# Fade from current alpha to 0
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(self, "modulate:a", 0.0, duration)

	tween.finished.connect(func():
		visible = false
	)

	return tween

func change_facing(facing_enum: int) -> void:
	# Map Character.Facing enum to sprite frames.
	match facing_enum:
		Character.Facing.DOWN:
			sprite.frame = 0  
		Character.Facing.RIGHT:
			sprite.frame = 1
		Character.Facing.LEFT:
			sprite.frame = 2
		Character.Facing.UP:
			sprite.frame = 3
		_:
			sprite.frame = 0



func begin_cutscene_walk(dir: String) -> void:
	pass

func end_cutscene_walk() -> void:
	pass
