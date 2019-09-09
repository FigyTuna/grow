extends Node2D

var SellSeed1 = preload("res://Items/Seed2.tscn")
var SellSeed2 = preload("res://Items/Seed3.tscn")
var SellFertilizer = preload("res://Items/Fertilizer.tscn")

var discovered = []

const cost1 = 10
const cost2 = 100
const cost3 = 30

signal buy(item, cost)
signal message(t)

func _ready():
	$ItemList.add_item("$" + str(cost1), SellSeed1.instance().icon)
	$ItemList.add_item("$" + str(cost2), SellSeed2.instance().icon)
	$ItemList.add_item("$" + str(cost3), SellFertilizer.instance().icon)
	$ItemList.set_item_disabled(0, true)
	$ItemList.set_item_disabled(1, true)
	$ItemList.set_item_disabled(2, true)

func update_discovered(n):
	if discovered.find(n) < 0:
		discovered.append(n)
		$dict.text = "Plants discovered: " + str(len(discovered)) + "/27"
		if n.find("Yellow Cherry Tree") > -1:
			emit_signal("message", "Discovered ")
			emit_signal("message", n + "1")
		else:
			emit_signal("message", "Discovered " + n + "!")
		if len(discovered) >= 27:
			emit_signal("message", "You discovered them all!")
			emit_signal("message", "Thanks for playing!")

func update_can_buy(money):
	if money >= cost1:
		$ItemList.set_item_disabled(0, false)
	else:
		$ItemList.set_item_disabled(0, true)
	if money >= cost2:
		$ItemList.set_item_disabled(1, false)
	else:
		$ItemList.set_item_disabled(1, true)
	if money >= cost3:
		$ItemList.set_item_disabled(2, false)
	else:
		$ItemList.set_item_disabled(2, true)

func _on_item_selected(index):
	if index == 0:
		emit_signal("buy", SellSeed1.instance(), cost1)
	elif index == 1:
		emit_signal("buy", SellSeed2.instance(), cost2)
	else:
		emit_signal("buy", SellFertilizer.instance(), cost3)
