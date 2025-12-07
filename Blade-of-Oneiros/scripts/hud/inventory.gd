extends Node

var potions: int = 0
var keys: int = 0

signal inventory_changed

func add_potion(amount: int = 1):
	print("add pot")
	potions += amount
	emit_signal("inventory_changed")

func use_potion() -> bool:
	if potions > 0:
		print("use pot")
		potions -= 1
		emit_signal("inventory_changed")
		return true
	
	return false

func add_key(amount: int = 1):
	keys += amount
	emit_signal("inventory_changed")

func use_key() -> bool:
	if keys > 0:
		keys -= 1
		emit_signal("inventory_changed")
		return true
	
	return false
