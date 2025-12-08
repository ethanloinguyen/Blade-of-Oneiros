extends CanvasLayer

@onready var potion_label = $InventoryPanel/PotionBox/PotionLabel
@onready var key_label = $InventoryPanel/KeyBox/KeyLabel

func _ready():
	# Listen to changes from the inventory
	Inventory.inventory_changed.connect(_update_inventory_display)
	_update_inventory_display() # initialize display
	print("HUD loaded!")
	#Added by Alfred
	if has_node("DialogUI"):
		var ui := $DialogUI
		print("DEBUG: HUD registering DialogUI with DialogueOrchestrator:", ui)
		DialogueOrchestrator.set_dialog_ui(ui)
	else:
		print("DEBUG: HUD could NOT find DialogUI as a child")
func _update_inventory_display():
	potion_label.text = str(Inventory.potions)
	key_label.text = str(Inventory.keys)
