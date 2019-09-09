extends Node2D

# warning-ignore:unused_class_variable
export var item_name = ""
# warning-ignore:unused_class_variable
export (Resource)var icon
# warning-ignore:unused_class_variable
export(int, "Seed", "Essence", "Fruit", "Stalk", "Fertilizer") var item_type
# warning-ignore:unused_class_variable
export var sell_value = 1
# warning-ignore:unused_class_variable
export var combine_amount = -1
# warning-ignore:unused_class_variable
export (Resource)var combine_item

# warning-ignore:unused_class_variable
var quantity = 1

func _ready():
	pass
