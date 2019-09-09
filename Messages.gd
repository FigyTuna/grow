extends Node2D

var Message = preload("res://Message.tscn")

var messages = []

var hints = [
	["Hint: If a plant is sparkling,","tap it 3 times to harvest it."],
	["Hint: If you are out of room,", "press and hold on a plant","to get rid of it."],
	["Hint: You can sell items to", "buy seeds and fertilizer."],
	["Hint: Try to maintain", "enough of each type of", "seed and essence."],
	["Hint: Fertilizer will make a", "plant ready to harvest", "immediately."],
	["Hint: You can use essence", "more than once on a", "budding plant."],
	["Hint: When a plant slows", "down its movement, it is", "about to wilt."],
	["Hint: Combine lots of stalk", "together to unlock extra","space for plants."],
	["Hint: You can sell fruit", "for a high price."],
	["Hint: You can combine lots", "of one kind of natural", "material into fertilizer."],
	["Hint: Some essence has a", "random chance of turning", "a bud into a rare plant."],
	["Hint: Sometimes, you can", "use fruit in place of", "essence."]
]
var hint_timer = 40
var hint_count = 0

const spacing = 50

func _physics_process(delta):
	if hint_count < len(hints):
		hint_timer += delta
		if hint_timer >= 80:
			hint_timer = 0
			for m in hints[hint_count]:
				message(m)
				play_hint()
			hint_count += 1

func message(t, pd=false):
	var m = Message.instance()
	m.get_child(0).text = t
	add_child(m)
	m.get_child(1).play("fadeout")
	m.get_child(1).connect("animation_finished", self, "finish")
	messages.push_front(m)
	if pd:
		play_die()
	if t.find("Discovered") > -1:
		play_discover()
	do_spacing()

func finish(_n):
	if len(messages) > 0:
		messages.resize(len(messages) - 1)
	do_spacing()

func do_spacing():
	for i in range(len(messages)):
		messages[i].position.y = spacing * (len(messages) - 1 - i)

func play_die():
	$Die.play()
	
func play_hint():
	$Hint.play()

func play_harvest():
	$Harvest.play()
	
func play_buy():
	$Buy.play()
	
func play_sell():
	$Sell.play()
	
func play_combine():
	$Combine.play()

func play_discover():
	$Discover.play()