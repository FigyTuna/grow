extends Node2D

var current_plant = null

func _ready():
	pass

func set_plant(p):
	current_plant = p
	add_child(p)
	p.connect("grow2", self, "remove_ground")
	p.connect("die", self, "remove_plant")

func remove_ground():
	$Ground.visible = false

func remove_plant(_m="",_t=false):
	if current_plant:
		var items = current_plant.destroy()
		current_plant.queue_free()
		current_plant = null
		$Ground.visible = true
		return items
	else:
		return null

func harvest():
	if current_plant:
		return current_plant.harvest()
	else:
		return null

func change(item, Plants):
	if current_plant:
		return current_plant.change(item, Plants)
	return false

func fertilize():
	if current_plant:
		return current_plant.fertilize()
	return false

func get_colors():
	var colors = {}
	if current_plant:
		colors["light"] = current_plant.fd().light
		colors["dark"] = current_plant.fd().dark
		colors["bg"] = current_plant.fd().bg
	else:
		colors["dark"] = Color(.4,.4,.4,1)
		colors["light"] = Color(.6,.6,.6,1)
		colors["bg"] = Color(.9,.9,.9,1)
	return colors