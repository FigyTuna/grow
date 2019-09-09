extends Node2D

var Space = preload("res://Space.tscn")

var spaces = []
var no_spaces = 0

var old_space = 0
var old_colors = {}
var new_colors = {}
var color_timer = .9

var colorizer

func _ready():
	old_colors["dark"] = Color(.4,.4,.4,1)
	old_colors["light"] = Color(.6,.6,.6,1)
	old_colors["bg"] = Color(.9,.9,.9,1)
	new_colors = old_colors
	add_space()
	add_space()
	add_space()

func _physics_process(delta):
	if color_timer >= 1:
		color_timer = 1
	else:
		color_timer += 2 * delta
		var colors = {}
		colors["light"] = Color(new_colors["light"] * color_timer + old_colors["light"] * (1 - color_timer))
		colors["dark"] = Color(new_colors["dark"] * color_timer + old_colors["dark"] * (1 - color_timer))
		colors["bg"] = Color(new_colors["bg"] * color_timer + old_colors["bg"] * (1 - color_timer))
		colorizer.set_shader_param("light", colors["light"])
		colorizer.set_shader_param("dark", colors["dark"])
		colorizer.set_shader_param("bg", colors["bg"])

func add_space():
	var space = Space.instance()
	space.position.x = no_spaces * 600
	no_spaces += 1
	$Node2D.add_child(space)
	spaces.append(space)

func go_to_space(num):
	position.x = -(600 * num) + 300
	if num > old_space:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("move_left")
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("move_right")
	old_space = num
	update_colors(num)

func update_colors(num,dead=false):
	set_colors(spaces[num].get_colors(dead))

func set_colors(colors):
	old_colors = new_colors
	new_colors = colors
	color_timer = 0

func is_occupied(space):
	return spaces[space].current_plant != null

func plant(space, p):
	spaces[space].set_plant(p)

func harvest(space):
	return spaces[space].harvest()

func destroy(space):
	return spaces[space].remove_plant()

func change(space, item, Plants):
	return spaces[space].change(item, Plants)

func fertilize(space):
	return spaces[space].fertilize()