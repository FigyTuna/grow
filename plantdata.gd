extends Node2D

# warning-ignore:unused_class_variable
export var plant_name = ""
# warning-ignore:unused_class_variable
export var baby_stage = 20
# warning-ignore:unused_class_variable
export var until_adult = 100
# warning-ignore:unused_class_variable
export var min_life = 600
# warning-ignore:unused_class_variable
export var max_life = 700
# warning-ignore:unused_class_variable
export var harvest_time = 100

export (Array, int)var chances
export (Array, int, "Apple","Cherry","Stalk","S1","S2","S3","S4","E1","E2","E3","E4")var item_enum

export var max_harvested = 1

# warning-ignore:unused_class_variable
export (Color)var dark
# warning-ignore:unused_class_variable
export (Color)var bg
# warning-ignore:unused_class_variable
export (Color)var light

export (Array, String, "Disabled", "Happy Essence", "Fun Essence", "Magic Essence", "Special Essence", "Apple", "Cherry")var change_items
export (Array, Array, int, "1RP","2YT","3GV","4PL","5PM","6YP","7PT","8PT","9BM","10OL","11TV","12RT","13PM","14PV","15PL","16SL","17GL","18SM","19GP","20OP","RA","GA","RC","YC","GB","YB","GB")var changes_enum

func _ready():
	$AnimationPlayer.play("sway")

# warning-ignore:unused_argument
func harvest(s):
	var ret = []
	var num = (randi() % max_harvested) + 1
# warning-ignore:unused_variable
	for i in range(num):
		var total = 0
		for chance in chances:
			total += chance
		var choice = randi() % total
		var idx = 0
		for chance in chances:
			if choice < chance:
				ret.append(item_enum[idx])
				break
			idx += 1
			choice -= chance
	return ret

func destroy(s):
	var ret = []
	var extra = 0
	if s > 0:
		extra += max_harvested
# warning-ignore:unused_variable
	for i in range((randi() % 2) + extra + 1):
		var total = 0
		for chance in chances:
			total += chance
		var choice = randi() % total
		var idx = 0
		for chance in chances:
			if choice < chance:
				ret.append(item_enum[idx])
				break
			idx += 1
			choice -= chance
	return ret

# warning-ignore:unused_argument
func ready_action(s):
	return false#this will get called a lot

func change(item):
	var idx = 0
	for ci in change_items:
		if item.item_name == ci:
			return changes_enum[idx][randi() % len(changes_enum[idx])]
		idx += 1
	return null

func full_harvest(stage):
	return stage > 0