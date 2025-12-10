extends Control

@export var pages: Array[Texture2D] = [] 
@export var action: StringName = "attack"  
@onready var page_texture: TextureRect = $TextureRect

var _page_index: int = 0
var _is_open: bool = false


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)


func open_tutorial() -> void:
	if pages.is_empty():
		return

	_page_index = 0
	_set_page()
	visible = true
	_is_open = true
	set_process_unhandled_input(true)

	GameState.input_locked = true
	hud.visible = false
	print("Tutorial opened")


func close_tutorial() -> void:
	visible = false
	_is_open = false
	set_process_unhandled_input(false)

	GameState.input_locked = false
	hud.visible = true
	print("Tutorial closed")


func _set_page() -> void:
	if _page_index >= 0 and _page_index < pages.size():
		page_texture.texture = pages[_page_index]
		print("Showing tutorial page:", _page_index)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event is InputEventKey and event.pressed:
		_advance_page()
		return

	if event.is_action_pressed(action):
		_advance_page()
		return


func _advance_page() -> void:
		_page_index += 1
		if _page_index >= pages.size():
			close_tutorial()
		else:
			_set_page()
