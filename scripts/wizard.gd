extends Node2D

@onready var main_manager = get_tree().current_scene

var type = 0

var angle = 0
var speed = 10000

var walking = 0.0

const spawn_locs = [
	1.8,
]

func _ready() -> void:
	#speed = randi_range(5000, 15000)
	pass
	
func set_type(t: int):
	var planet_scale = main_manager.get_planet_scale()
	var rad_dist = 1000 / (2 * PI * main_manager.get_planet_scale())
	type = 0
	match type:
		0: 
			speed = 1200
			print(rad_dist)
			angle = spawn_locs[0] + randf_range(-rad_dist, rad_dist)

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
	if walking == 0 and randi_range(0, 100) == 0:
		#var norm_angle = angle % (2*PI)
		if randi_range(0,1) == 0:
			walking = -1.0
		else:
			walking = 1.0
	elif randi_range(0, 3) == 0:
		walking = 0.0
