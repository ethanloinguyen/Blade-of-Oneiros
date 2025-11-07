class_name Player
extends Character

var up_cmd: Command
var down_cmd: Command
var left_cmd: Command
var right_cmd: Command
var attack_cmd: Command
var idle_cmd: Command

func _ready() -> void:
	bind_commands()

func _physics_process(delta: float) -> void:
	var command: Command = get_input_command()
	if command:
		command.execute(self)
	super(delta)  # applies physics via Character._physics_process()

func bind_commands() -> void:
	up_cmd = MoveUpCommand.new()
	down_cmd = MoveDownCommand.new()
	left_cmd = MoveLeftCommand.new()
	right_cmd = MoveRightCommand.new()
	attack_cmd = AttackCommand.new()
	idle_cmd = IdleCommand.new()

# Returns the appropriate command based on input.
func get_input_command() -> Command:
	if Input.is_action_just_pressed("attack"):
		return attack_cmd

	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if dir == Vector2.ZERO:
		return idle_cmd

	if abs(dir.x) > abs(dir.y):
		return right_cmd if dir.x > 0 else left_cmd
	else:
		return down_cmd if dir.y > 0 else up_cmd
