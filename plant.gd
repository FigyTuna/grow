extends Node2D

var age = 0
var baby = true
var adult = false

var harvest_timer = 0
var stage = 0

var lifetime

var h_anim_timer = 1

var harvestable = false

signal grow1(n)
signal grow2()
signal die(m)

func _ready():
	$AnimationPlayer.play("bud_sway")

func harvest():
	if harvest_timer >= fd().harvest_time:
		var ret = fd().harvest(stage)
		harvest_timer = 0
		stage = 0
		h_anim_timer = 5
		return ret
	else:
		return null

func destroy():
	if adult:
		return fd().destroy(stage)
	else:
		return null

func change(item, Plants):
	if baby:
		var new_plant = Plants[fd().change(item)].instance()
		if new_plant:
			fd().queue_free()
			set_plant_data(new_plant)
			return new_plant
	return false

func fertilize():
	if baby:
		leave_baby()
	elif not adult:
		enter_adult()
	elif stage < 3:
		stage = 3
		harvest_timer = fd().harvest_time * 3
		fd().ready_action(3)
	else:
		return false
	return true

func leave_baby():
	baby = false
	$Bud.visible = false
	$Data.visible = true
	$Data.scale.x = 0.2
	$Data.scale.y = 0.2
	lifetime = (randi() % (fd().max_life - fd().min_life)) + fd().min_life
	emit_signal("grow1", fd().plant_name)

func enter_adult():
	adult = true
	$AnimationPlayer.play("grow")
	emit_signal("grow2")

func _physics_process(delta):
	age += delta
	if adult:
		harvest_timer += delta
		if stage < 1 and harvest_timer >= fd().harvest_time:
			fd().ready_action(1)
			stage = 1
		elif stage < 2 and harvest_timer >= fd().harvest_time * 2:
			fd().ready_action(2)
			stage = 2
		elif stage < 3 and harvest_timer >= fd().harvest_time * 3:
			fd().ready_action(3)
			stage = 3
		if h_anim_timer > 1:
			fd().get_child(0).playback_speed = h_anim_timer
			h_anim_timer -= delta * 2
		if not harvestable and stage > 0:
			$Sparkle.visible = true
			$Sparkle2.visible = true
			$AnimationPlayer2.play("sparkle")
			harvestable = true
		elif harvestable and stage < 1:
			$AnimationPlayer2.seek(3, true)
		if age >= lifetime:
			emit_signal("die", str(fd().plant_name) + " wilted.", true)
		elif age >= lifetime - 60:
			fd().get_child(0).playback_speed = 0.25
	elif baby and age >= fd().baby_stage:
		leave_baby()
	elif not adult and age >= fd().until_adult:
		enter_adult()

func set_plant_data(pd):
	$Data.add_child(pd)

func fd():
	return $Data.get_child(0)