extends Node

@export var player : Node
@export var camera : Camera2D
@export var ui: Node

var ponderings = 50.0
const PLAYER_SPEED = 10000


const WIZARD = preload("uid://dnab7mgo1j34n")


func get_active_cost(type: int) -> int:
	match type:
		0: return 10
		
	return 100000000
	
func get_pps(type: int) -> int:
	match type:
		0: return 1
		
	return 1

func _ready() -> void:
	pass
	
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
	# handel monoliths
	var planet_scale = get_planet_scale()
	for mono in $Monoliths.get_children():
		if ponderings >= mono.min_ponderings:
			mono.active = true
			mono.show()
			mono.position = Vector2.from_angle(mono.angle_loc) * planet_scale
			mono.rotation = mono.angle_loc + PI / 2
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
	
func spawn_novice_mage():
	var wiz = WIZARD.instantiate()
	$NoviceMages.add_child(wiz)
	wiz.set_type(0)

func inc_ponderings(amt: float):
	ponderings += amt

func get_planet_scale() -> float:
	return log(ponderings + 1.0) * 100.0

func get_num_novice_mages() -> int:
	return len($NoviceMages.get_children())
	
func get_total_pps() -> float:
	var novice_mages = get_num_novice_mages()
	
	return novice_mages * float(get_pps(0))

func _on_addponders_timeout() -> void:
	inc_ponderings(get_total_pps() * 0.1)
