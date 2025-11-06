class_name State
extends RefCounted

var name:String
var on_enter:Callable
var on_update:Callable
var on_exit:Callable


# Use empty callable (i.e Callable()) when you don't want the func to do anything
func _init(_name:String, _on_enter : Callable, _on_update : Callable, _on_exit : Callable):
	name = _name
	on_enter = _on_enter
	on_update = _on_update
	on_exit = _on_exit
