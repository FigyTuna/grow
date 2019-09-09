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

export (int, "Apple","Cherry","Stalk","S1","S2","S3","S4","E1","E2","E3","E4")var item_enum

export var max_harvested = 1

# warning-ignore:unused_class_variable
export (Color)var dark
# warning-ignore:unused_class_variable
export (Color)var bg
# warning-ignore:unused_class_variable
export (Color)var light

func _ready():
	$AnimationPlayer.play("sway")

func harvest(s):
	var ret = []
# warning-ignore:unused_variable
	for i in range(min(s, max_harvested)):
		ret.append(item_enum)
	if max_harvested >= 3:
		$stage3.visible = false
	if max_harvested >= 2:
		$stage2.visible = false
	$stage1.visible = false
	return ret

func destroy(s):
	var ret = []
# warning-ignore:unused_variable
	for i in range(min(s, max_harvested) + 1):
		ret.append(item_enum)
	return ret

func ready_action(s):
	if s > 0 and max_harvested >= 1:
		$stage1.visible = true
	if s > 1 and max_harvested >= 2:
		$stage2.visible = true
	if s > 2 and max_harvested >= 3:
		$stage3.visible = true
	return true

# warning-ignore:unused_argument
func change(item):
	return null