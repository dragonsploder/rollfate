extends Node2D

@export var player : Node
@export var camera : Camera2D

var ponderings = 1.0
const PLAYER_SPEED = 10000

func _ready() -> void:
	pass
	

func _process(delta: float) -> void:
		
	if Input.is_action_just_pressed("a"):
		inc_ponderings(1.0)
	
	var rad_dist = PLAYER_SPEED / (2 * PI * get_planet_scale())
	if Input.is_action_pressed("l"):
		player.walk(-delta * rad_dist)
	elif Input.is_action_pressed("r"):
		player.walk(delta * rad_dist)
	
	# Update Camera
	camera.position = player.position
	camera.rotation = player.rotation

	

func inc_ponderings(amt: float):
	ponderings += amt

func get_planet_scale() -> float:
	return log(ponderings) * 100.0
