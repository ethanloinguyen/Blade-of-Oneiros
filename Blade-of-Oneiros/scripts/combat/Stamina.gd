extends Node
class_name Stamina

@export var max_stamina: float = 100.0
@export var recharge_rate: float = 20.0
@export var recharge_delay: float = 1.0
@export var slow_factor: float = 0.6
@export var player_base_speed: float = 100.0

var current: float = 100.0
var delay_timer: float = 0.0
var locked: bool = false   # exhausted state

signal stamina_changed
signal exhausted
signal recovered


func _init():
	current = max_stamina

func _process(delta):
	_regen(delta)

func try_use(amount: float) -> bool:
	if locked:
		return false
	
	if current > 0:
		current -= amount
		current = max(current, 0.0)
		delay_timer = recharge_delay
		_check_exhaustion()
		stamina_changed.emit()
		return true
	
	return false


func _regen(delta: float) -> void:
	if current < max_stamina:
		if delay_timer > 0:
			delay_timer -= delta
		else:
			current += recharge_rate * delta
			current = min(current, max_stamina)
	
	stamina_changed.emit()
	
	if locked and current >= max_stamina:
		locked = false
		recovered.emit()


func _check_exhaustion():
	if current <= 0 and not locked:
		locked = true
		exhausted.emit()


func reset_stamina():
	current = max_stamina
	stamina_changed.emit()
