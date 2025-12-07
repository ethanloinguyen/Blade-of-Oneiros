extends CanvasLayer

@onready var potion_label = $InventoryPanel/PotionBox/PotionLabel
@onready var key_label = $InventoryPanel/KeyBox/KeyLabel

func _ready():
	# Listen to changes from the inventory
	Inventory.inventory_changed.connect(_update_inventory_display)
	_update_inventory_display() # initialize display
	print("HUD loaded!")
func _update_inventory_display():
	potion_label.text = str(Inventory.potions)
	key_label.text = str(Inventory.keys)
