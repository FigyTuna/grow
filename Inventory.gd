extends Node2D

var Seed1 = preload("res://Items/Seed1.tscn")
var Fertilizer = preload("res://Items/Fertilizer.tscn")

var inv = []
var use_item = null
var use_quantity

var can_sell = false

func _ready():
	add_to_inv(Seed1.instance(), 3)
	add_to_inv(Fertilizer.instance(), 6)
	$Use.visible = false
	$Combine.visible = false
	$Sell.visible = false

func add_to_inv(item, q=1):
	var idx = 0
	var dup = false
	for i in inv:
		if item.item_name == i.item_name:
			i.quantity += q
			$ItemList.set_item_text(idx, "x" + str(i.quantity))
			dup = true
			break
		idx += 1
	if not dup:
		item.quantity = q
		inv.append(item)
		$ItemList.add_item("x" + str(item.quantity), item.icon)

func _on_item_selected(index):
	if not use_item:
		$UseSlot.add_item("x1", inv[index].icon)
		use_item = inv[index]
		use_quantity = 1
		inv[index].quantity -= 1
		update_count(index)
		
	elif use_item.item_name == inv[index].item_name:
		use_quantity += 1
		$UseSlot.set_item_text(0, "x" + str(use_quantity))
		inv[index].quantity -= 1
		update_count(index)
		
	update_buttons()

func _on_UseSlot_selected(_index):
	add_to_inv(use_item)
	use_quantity -= 1
	if use_quantity < 1:
		use_item = null
		$UseSlot.remove_item(0)
		check_for_no_seeds()
	else:
		$UseSlot.set_item_text(0, "x" + str(use_quantity))
	update_buttons()

func use_up(q = 1):
	use_quantity -= q
	if use_quantity < 1:
		use_item = null
		$UseSlot.remove_item(0)
	else:
		$UseSlot.set_item_text(0, "x" + str(use_quantity))
	update_buttons()

func check_for_no_seeds():
	var no_seeds = true
	for item in inv:
		if item.item_name.find("Seed") > -1:
			no_seeds = false
	if no_seeds and can_sell:
		add_to_inv(Seed1.instance(), 1)

func return_all():
	if use_item:
		add_to_inv(use_item, use_quantity)
		use_item = null
		$UseSlot.remove_item(0)
		update_buttons()

func update_count(idx):
	if inv[idx].quantity < 1:
		inv.remove(idx)
		$ItemList.remove_item(idx)
	else:
		$ItemList.set_item_text(idx, "x" + str(inv[idx].quantity))

func update_buttons():
	if use_item:
		if use_item.item_type != 3:
			$Use.visible = true
		else:
			$Use.visible = false
		if use_item.combine_amount > 0 and use_quantity >= use_item.combine_amount:
			$Combine.visible = true
		else:
			$Combine.visible = false
		if can_sell:
			$Sell.visible = true
		else:
			$Sell.visible = false
	else:
		$Use.visible = false
		$Combine.visible = false
		$Sell.visible = false

func load_game(data, Items):
	inv = []
	$ItemList.remove_item(0)
	$ItemList.remove_item(0)
	can_sell = data["can_sell"]
	for item_data in data["inv"]:
		var item = Items[item_data["id"]].instance()
		item.quantity = item_data["quantity"]
		inv.append(item)
		$ItemList.add_item("x" + str(item.quantity), item.icon)

func save_game():
	var data = {
		"can_sell": can_sell,
		"inv": []
	}
	for item in inv:
		data["inv"].append(item.save_game())
	return data