extends Node2D

var Plant = preload("res://plants/Plant.tscn")
var Plants = [
	preload("res://plants/RedPoppy.tscn"),
	preload("res://plants/YellowTulip.tscn"),
	preload("res://plants/GreenVine.tscn"),
	preload("res://plants/PinkLily.tscn"),
	preload("res://plants/PinkMum.tscn"),
	preload("res://plants/YellowPoppy.tscn"),
	preload("res://plants/PinkTulip.tscn"),
	preload("res://plants/PurpleTulip.tscn"),
	preload("res://plants/BlueMum.tscn"),
	preload("res://plants/OrangeLily.tscn"),
	preload("res://plants/TealVine.tscn"),
	preload("res://plants/RedTulip.tscn"),
	preload("res://plants/PurpleMum.tscn"),
	preload("res://plants/PinkVine.tscn"),
	preload("res://plants/PurpleVine.tscn"),
	preload("res://plants/SilverLily.tscn"),
	preload("res://plants/GoldLily.tscn"),
	preload("res://plants/SilverMum.tscn"),
	preload("res://plants/GoldPoppy.tscn"),
	preload("res://plants/OrangePoppy.tscn"),
	preload("res://plants/RedAppleTree.tscn"),
	preload("res://plants/GreenAppleTree.tscn"),
	preload("res://plants/RedCherryTree.tscn"),
	preload("res://plants/YellowCherryTree.tscn"),
	preload("res://plants/GreenBamboo.tscn"),
	preload("res://plants/YellowBamboo.tscn"),
	preload("res://plants/GoldBamboo.tscn")
]
var Items = [
	preload("res://Items/Apple.tscn"),
	preload("res://Items/Cherry.tscn"),
	preload("res://Items/Stalk.tscn"),
	preload("res://Items/Seed1.tscn"),
	preload("res://Items/Seed2.tscn"),
	preload("res://Items/Seed3.tscn"),
	preload("res://Items/Seed4.tscn"),
	preload("res://Items/Essence1.tscn"),
	preload("res://Items/Essence2.tscn"),
	preload("res://Items/Essence3.tscn"),
	preload("res://Items/Essence4.tscn"),
	preload("res://Items/Fertilizer.tscn")
]

var flower_is_held = false
var flower_held_time = 0

var tap_count = 0
var time_since_last_tap = 0

var current_space = 0

var inv_is_up = false
var dict_is_up = false

var money = 0

var hint_plant = true
var hint_fert = true
var hint_ess = true

var check_colors_timer = 0
var check_colors = false

var restart_timer = 0

const destroy_time = 1.2
const harvest_time = 0.4

func _ready():
	$AnimationPlayer.play("start")
	$SpaceMap.colorizer = $ColorRect.material
	$Dict.connect("message", $Messages, "message")
	load_game()

func _input(event):
	if event.is_action_pressed("left"):
		current_space -= 1
		if current_space < 0:
			current_space = 0
		else:
			if current_space < 1:
				$Left.visible = false
			$Right.visible = true
			$SpaceMap.go_to_space(current_space)
	
	if event.is_action_pressed("right"):
		current_space += 1
		if current_space >= $SpaceMap.no_spaces:
			current_space = $SpaceMap.no_spaces - 1
		else:
			if current_space >= $SpaceMap.no_spaces - 1:
				$Right.visible = false
			$Left.visible = true
			$SpaceMap.go_to_space(current_space)
	
	if event.is_action_pressed("inv"):
		if inv_is_up:
			close_menu()
		else:
			if hint_plant:
				$Messages.message("Hint: Try planting a seed.")
				$Messages.message("Tap the check mark to use.")
				$Messages.play_hint()
				hint_plant = false
			elif hint_fert:
				$Messages.message("Hint: Use fertilizer to help")
				$Messages.message("a plant grow faster.")
				$Messages.play_hint()
				hint_fert = false
			if dict_is_up:
				close_dict()
			$Inventory.visible = true
			$TouchScreenButton.visible = false
			inv_is_up = true
	
	if event.is_action_pressed("dict"):
		if dict_is_up:
			close_dict()
		else:
			if inv_is_up:
				close_menu()
			$Dict.visible = true
			$TouchScreenButton.visible = false
			dict_is_up = true
	
	if event.is_action_pressed("flower"):
		flower_is_held = true
		time_since_last_tap = 0
		tap_count += 1
	elif event.is_action_released("flower"):
		flower_is_held = false
	
	if event.is_action_pressed("use"):
		if $Inventory.use_item.item_type == 0:
			if not $SpaceMap.is_occupied(current_space):
				var plant = Plant.instance()
				plant.connect("grow1", $Dict, "update_discovered")
				plant.connect("die", $Messages, "message")
				plant.connect("die", self, "die_change_colors")
				var inst
				if $Inventory.use_item.item_name == "Basic Seed":
					inst = Plants[0].instance()
				elif $Inventory.use_item.item_name == "Bulky Seed":
					inst = Plants[1].instance()
				elif $Inventory.use_item.item_name == "Variety Seed":
					inst = Plants[2].instance()
				else:
					inst = Plants[3].instance()
				plant.set_plant_data(inst)
				$Inventory.use_up()
				$SpaceMap.plant(current_space, plant)
				$SpaceMap.update_colors(current_space)
				close_menu()
		elif $Inventory.use_item.item_type == 1 or $Inventory.use_item.item_type == 2:
			var new_plant = $SpaceMap.change(current_space, $Inventory.use_item, Plants)
			if new_plant:
				$Inventory.use_up()
				var colors = {}
				colors["light"] = new_plant.light
				colors["dark"] = new_plant.dark
				colors["bg"] = new_plant.bg
				$SpaceMap.set_colors(colors)
				close_menu()
		elif $Inventory.use_item.item_type == 4:
			if $SpaceMap.fertilize(current_space):
				$Inventory.use_up()
				close_menu()
	
	if event.is_action_pressed("save"):
		save_game()
	
	if event.is_action_pressed("restart"):
		if restart_timer > 0:
			restart()
		else:
			$Messages.message("Are you sure you want")
			$Messages.message("to start over? Press")
			$Messages.message("restart again to confirm.")
			restart_timer = 5
	
	if event.is_action_pressed("sell"):
		var gain = $Inventory.use_item.sell_value * $Inventory.use_quantity
		$Messages.message("Sold " + $Inventory.use_item.item_name + " x" + str($Inventory.use_quantity))
		$Messages.message("Got $" + str(gain) + ".")
		money += gain
		$Inventory.use_up($Inventory.use_quantity)
		$Messages.play_sell()
		update_money()
		$Inventory.check_for_no_seeds()
	
	if event.is_action_pressed("combine"):
		if $Inventory.use_item.item_type == 3:
			$SpaceMap.add_space()
			$Messages.message("Unlocked an extra space!")
			$Right.visible = true
		else:
			$Messages.message("Made fertilizer.")
			$Inventory.add_to_inv($Inventory.use_item.combine_item.instance())
			$Inventory.check_for_no_seeds()
		$Messages.play_combine()
		$Inventory.use_up($Inventory.use_item.combine_amount)

func die_change_colors(_n,_t):
	check_colors_timer = 0.1
	check_colors = true

func update_money():
	$Inventory/Money.text = "$" + str(money)
	$Dict/Money.text = "$" + str(money)
	$Dict.update_can_buy(money)

func close_menu():
	$Inventory.visible = false
	$Inventory.return_all()
	$TouchScreenButton.visible = true
	inv_is_up = false

func close_dict():
	$Dict.visible = false
	$TouchScreenButton.visible = true
	dict_is_up = false

func _physics_process(delta):
	if flower_is_held:
		flower_held_time += delta
	else:
		flower_held_time = 0
	
	if flower_held_time > destroy_time:
		flower_held_time = 0
		tap_count = 0
		var items = $SpaceMap.destroy(current_space)
		if items:
			$Messages.play_die()
			for item_int in items:
				var item = Items[item_int].instance()
				$Messages.message("Got " + item.item_name + ".")
				$Inventory.add_to_inv(item)
		$SpaceMap.update_colors(current_space)
	
	time_since_last_tap += delta
	
	if time_since_last_tap > harvest_time:
		tap_count = 0
	
	if tap_count >= 3:
		tap_count = 0
		var items = $SpaceMap.harvest(current_space)
		if items != null:
			$Messages.play_harvest()
			for item_int in items:
				var item = Items[item_int].instance()
				$Messages.message("Got " + item.item_name + ".")
				$Inventory.add_to_inv(item)
			if hint_ess:
				$Messages.message("Hint: Use essence on a plant")
				$Messages.message("before it has sprouted and")
				$Messages.message("see what happens...")
				$Messages.play_hint()
				hint_ess = false
	
	if not $Inventory.can_sell and len($Dict.discovered) >= 3:
		$Inventory.can_sell = true
	
	if check_colors and check_colors_timer <= 0:
		$SpaceMap.update_colors(current_space)
		check_colors = false
	elif check_colors:
		check_colors_timer -= delta
	
	if restart_timer > 0:
		restart_timer -= delta

func _on_buy(item, cost):
	if money >= cost:
		$Messages.play_buy()
		$Inventory.add_to_inv(item)
		money -= cost
		update_money()

func restart():
	var save = File.new()
	if save.file_exists("user://savedata.json"):
		save.open("user://savedata.json", File.WRITE)
		save.store_line(to_json({"new":true}))
		save.close()
	
	get_tree().reload_current_scene()

func load_game():
	var save = File.new()
	if not save.file_exists("user://savedata.json"):
		return
	
	save.open("user://savedata.json", File.READ)
	var data = parse_json(save.get_as_text())
	if not data["new"]:
		money = data["money"]
		current_space = data["current_space"]
		$Dict.load_game(data["dict"])
		$SpaceMap.load_game(data["plants"], Plant, Plants, $Dict, $Messages, self)
		$Inventory.load_game(data["inv"], Items)
		$Messages.load_game(data["hints"])
	save.close()
	$SpaceMap.go_to_space(current_space)
	if current_space > 0:
		$Left.visible = true
	if current_space >= $SpaceMap.no_spaces - 1:
		$Right.visible = false
	$SpaceMap.update_colors(current_space)
	update_money()
	
	hint_ess = false
	hint_fert = false
	hint_plant = false

func save_game():
	var save = File.new()
	save.open("user://savedata.json", File.WRITE)
	var data = {
		"new": false,
		"money": money,
		"current_space": current_space,
		"plants": $SpaceMap.save_game(),
		"inv": $Inventory.save_game(),
		"dict": $Dict.save_game(),
		"hints": $Messages.save_game()
	}
	save.store_line(to_json(data))
	save.close()
	$Messages.message("Game saved.")
	$Messages.play_combine()
