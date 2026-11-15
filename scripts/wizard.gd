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


func _on_timer_timeout() -> void:
	if tree:
		return
	if walking == 0 and randi_range(0, 100) == 0:
		#var norm_angle = angle % (2*PI)
		if randi_range(0,1) == 0:
			walking = -1.0
		else:
			walking = 1.0
	elif randi_range(0, 3) == 0:
		walking = 0.0
