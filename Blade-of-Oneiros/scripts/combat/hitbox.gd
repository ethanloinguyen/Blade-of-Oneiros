class_name Hitbox
extends Area2D

@export var damage:int
@export var attack_duration:float

var duration_timer:Timer

# list of hurboxes immune to this attack. so no attacks hit twice
var immune_healths:Array[Health]


func _ready() -> void:
	area_entered.connect(func(a):
		if a is Health and not immune_healths.has(a):
			a.current_health -= damage
			print("Attack hit: " + a.name)
	)
	duration_timer = Timer.new()
	duration_timer.one_shot = true
	add_child(duration_timer)


func set_active(active:bool) -> void:
	if active:
		duration_timer.start(attack_duration)
	else:
		immune_healths.clear()
	process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED


func is_attack_finished() -> bool:
	return duration_timer.time_left == 0
