extends Node

@export var player : Node
@export var camera : Camera2D
@export var ui: Node

var ponderings = 3.0
var planet_scale = 1
const PLAYER_SPEED = 10000


const WIZARD = preload("uid://dnab7mgo1j34n")


func get_active_cost(type: int) -> int:
	match type:
		0: return 10 + 5 * get_num_wizards(0)
		1: return 100 + 50 * get_num_wizards(1)
		2: return 1000 + 500 * get_num_wizards(2)
		
	return 100000000
	
func get_pps(type: int) -> int:
	match type:
		0: return 1
		1: return 10
		2: return 100
		
	return 1

func _ready() -> void:
	planet_scale = get_planet_scale_raw()
	
func show_text_popup(text: String):
	ui.show_text_popup(text)

func hide_text_popup():
	ui.hide_text_popup()


func hide_mono_stuff(mono: Node):
	mono.active = false
	mono.hide()
	if is_instance_valid(player.active_monolith) and mono.type == player.active_monolith.type:
		hide_text_popup()
		player.active_monolith = null
		

func _process(delta: float) -> void:
	planet_scale = lerp(float(planet_scale), get_planet_scale_raw(), 0.99 * delta)
	
	# handel monoliths
	for mono in $Monoliths.get_children():
		if ponderings >= mono.min_ponderings:
			mono.active = true
			mono.show()
			mono.position = Vector2.from_angle(mono.angle_loc) * planet_scale
			mono.rotation = mono.angle_loc + PI / 2
			if mono.has_overlapping_areas():
				player._on_player_entered(mono)
		else:
			hide_mono_stuff(mono)

		
	if Input.is_action_just_pressed("a"):
		if is_instance_valid(player.active_monolith):
			player.active_monolith.attempt_active_monolith()
		else:
			inc_ponderings(1.0)
	
	var rad_dist = PLAYER_SPEED / (2 * PI * get_planet_scale())
	if Input.is_action_pressed("l"):
		player.walk(-delta * rad_dist)
	elif Input.is_action_pressed("r"):
		player.walk(delta * rad_dist)
	
	# Update Camera
	camera.position = player.position
	camera.rotation = player.rotation

func dec_ponderings(amt: float) -> bool:
	if amt < ponderings:
		ponderings -= amt
		return true
	return false
	
func spawn_mage(type):
	var wiz = WIZARD.instantiate()
	match type:
		0: $NoviceMages.add_child(wiz)
		1: $JournymanMages.add_child(wiz)
		2: $ElderMages.add_child(wiz)
	wiz.set_type(type)

func inc_ponderings(amt: float):
	ponderings += amt

func get_planet_scale_raw() -> float:
	return log(ponderings + 1.0) * 100.0
	
func get_planet_scale() -> float:
	return planet_scale

func get_num_wizards(type) -> int:
	match type:
		0: return len($NoviceMages.get_children())
		1: return len($JournymanMages.get_children())
		2: return len($ElderMages.get_children())
		
	return 0
	
func get_total_pps() -> float:
	var t = 0.0
	for i in range(0,3):
		t += get_num_wizards(i) * float(get_pps(i))
	return t
	
func _on_addponders_timeout() -> void:
	inc_ponderings(get_total_pps() * 0.1)
