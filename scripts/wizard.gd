extends Node2D

@onready var main_manager = get_tree().current_scene

var type = 0

var angle = 0
var speed = 10000

var walking = 0.0

const spawn_locs = [
	1.8,
	3,
	5,
	5.5,
	2.5
]

var tree = false

func _ready() -> void:
	#speed = randi_range(5000, 15000)
	pass
	
func set_type(t: int):
	var planet_scale = main_manager.get_planet_scale()
	var rad_dist = 1000 / (2 * PI * main_manager.get_planet_scale())
	type = t
	match type:
		0: 
			speed = 1200
			$AnimatedSprite2D.play("novice_idle")
		1:
			speed = 1000
			$AnimatedSprite2D.play("journyman_idle")
		2:
			speed = 800
			$AnimatedSprite2D.play("elder_idle")
		3:
			speed = 500
			$AnimatedSprite2D.play("wizzer_idle")
		4:
			speed = 500
			$AnimatedSprite2D.play("wizzer_idle")
		9:
			tree = true
			angle = randf_range(0, 2*PI)
			
			$AnimatedSprite2D.play("tree")
			self.scale = Vector2(1.5, 1.5)
			$AnimatedSprite2D.position.y -= 30 + randf_range(0, 10)
			$Area2D.position.y -= 30
			z_index -= 5
			return
	
	z_index += randi_range(0,3)
	
	angle = spawn_locs[type] + randf_range(-rad_dist, rad_dist)
	

func _process(delta: float) -> void:
	var planet_scale = main_manager.get_planet_scale()
	var rad_dist = speed / (2 * PI * main_manager.get_planet_scale())
	angle += walking * rad_dist * delta
	
	if walking != 0.0:
		if walking > 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
	
	# Place wiz in correct spot
	self.position = Vector2.from_angle(angle) * planet_scale
	self.rotation = angle + PI / 2

var thinkings = [
	"What is 2+2?",
	"Why 42?",
	"Where are my feet?",
	"How old am I?",
	"Why is it blue?",
	"Am I doing it right?",
	"I can feel my brain growing?",
	"If money doesn't grow on trees, why do banks have branches?",
	"Shouldn't the Air and Space museum be empty?",
	"What they doing over there?",
	"I wonder if those wizards get dental?",
	"Why do you bake cookies but cook bacon?",
	"I like pie.",
	"Is there another word for synonym?",
	"Why do they call them 'apartments' if they’re all stuck together?",
	"Why is there an expiration date on sour cream?",
	"If Apple made a car would it have Windows?",
	"Where are my camouflage pants?",
	"Does soap ever get dirty?",
	"I wish I was making a game for the 2026 Roll Your Fate Jam.",
	"Why do noses run and feet smell?",
	"If two apples are a pair, are two pears an apple?",
	"Can something be both new and improved?",
	"What happens if you’re scared half to death twice?",
	"Why doesn’t glue get stuck in the bottle?",
]

func _on_timer_timeout() -> void:
	if randi_range(0, 400) == 0:
		$thinkings.text = thinkings.pick_random()
		$thinkings.show()
	if randi_range(0, 30) == 0:
		$thinkings.hide()
	if randi_range(0, 1000) == 0:
		$thinker.stream = main_manager.think_sounds.pick_random()
		$thinker.play()
	if tree:
		return
	if walking == 0 and randi_range(0, 100) == 0:
		if z_index >10:
			z_index -= 6
			$AnimatedSprite2D.position.y -= 10
		#var norm_angle = angle % (2*PI)
		if randi_range(0,1) == 0:
			walking = -1.0
		else:
			walking = 1.0
	elif randi_range(0, 3) == 0:
		walking = 0.0
