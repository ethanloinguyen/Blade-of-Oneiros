extends CanvasLayer

@onready var potion_label = get_node("InventoryPanel/PotionBox/PotionLabel")
@onready var key_label = get_node("InventoryPanel/KeyBox/KeyLabel")

func _ready():
	# Listen to changes from the inventory
	print("HUD path = ", get_path())
	print("Potion label exists? ", get_node_or_null("InventoryPanel/PotionBox/PotionLabel"))
	print("Key label exists? ", get_node_or_null("InventoryPanel/KeyBox/KeyLabel"))
	Inventory.inventory_changed.connect(_update_inventory_display)
	_update_inventory_display() # initialize display
	print("HUD loaded!")


func _update_inventory_display():
	print("HUD updating… potions=", Inventory.potions)
	potion_label.text = str(Inventory.potions)
	key_label.text = str(Inventory.keys)
