class_name PressurePlateGroup
extends Node

signal all_pressed
signal any_released

var total: int = 0
var pressed: int = 0


func _ready() -> void:
	for child in get_children():
		if child is PressurePlate:
			total += 1
			child.activated.connect(_on_plate_activated)
			child.deactivated.connect(_on_plate_deactivated)

	print("PlateGroup: total plates =", total)


func _on_plate_activated() -> void:
	pressed += 1
	print("PlateGroup: pressed", pressed, "/", total)

	if pressed == total:
		print("PlateGroup: EMIT all_pressed")
		all_pressed.emit()


func _on_plate_deactivated() -> void:
	pressed -= 1
	print("PlateGroup: released", pressed, "/", total)

	any_released.emit()
