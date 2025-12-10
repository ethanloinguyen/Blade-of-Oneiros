class_name TriggerArea
extends Area2D

signal triggered(body: Node)
@onready var shape: CollisionShape2D = $CollisionShape2D
@export var single_use: bool = false
var used: bool = false

func _ready() -> void:

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void: 
	if single_use and used:
		return
	
	emit_signal("triggered", body)
	if single_use:
		used = true
		shape.disabled = true
