extends Node2D

@export var action: StringName = "interact"  

@onready var area: Area2D = $Area2D
@onready var prompt: Node2D = $Prompt
@onready var tutorial_panel: Control = $CanvasLayer/TutorialPanel
@onready var anim: AnimationPlayer = $Prompt/AnimationPlayer
var _player_near: bool = false


func _ready() -> void:
	anim.play("press")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	prompt.visible = false
	set_process_unhandled_input(true)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true
		prompt.visible = true
		print("Player entered tutorial area")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
		prompt.visible = false
		print("Player left tutorial area")


func _unhandled_input(event: InputEvent) -> void:
	if GameState.input_locked:
		return

	if not _player_near:
		return

	if event.is_action_pressed(action):
		_open_tutorial()

func _open_tutorial() -> void:
	if tutorial_panel and "open_tutorial" in tutorial_panel:
		print("Opening tutorial")
		tutorial_panel.call("open_tutorial")
