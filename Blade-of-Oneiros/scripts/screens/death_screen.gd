extends Node

@onready var menu_button = $CanvasLayer/MenuButton
@onready var respawn_button = $CanvasLayer/Respawn
@onready var background = $CanvasLayer/ColorRect
@onready var you_died_text = $CanvasLayer/YouDied


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_button.pressed.connect(_on_menu_button_pressed)
	respawn_button.pressed.connect(_on_respawn_button_pressed)
	_hide_death_screen()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(GameState.game_over):
		#await SceneTransition.fade_out()
		hud.visible = false
		background.visible = true
		menu_button.visible = true
		respawn_button.visible = true
		you_died_text.visible = true
	else:
		_hide_death_screen()


func _on_menu_button_pressed():
	_hide_death_screen()
	GameState.game_started = false
	GameState.game_over = false
	GameState.has_armor = false
	get_tree().change_scene_to_file("res://scenes/title_scene/title_screen.tscn")


func _on_respawn_button_pressed():
	_hide_death_screen()
	#get_tree().change_scene_to_file("res://scenes/title_scene/title_screen.tscn")
	#
	GameState.game_over = false
	GameState.is_respawning = true
	if PlayerManagement.player and is_instance_valid(PlayerManagement.player):
		if "reset_player" in PlayerManagement.player:
			PlayerManagement.player.reset_player()
	PlayerManagement.change_level(GameState.last_scene_path, GameState.last_spawn_tag)


func _hide_death_screen():
	background.visible = false
	menu_button.visible = false
	respawn_button.visible = false
	you_died_text.visible = false
	
