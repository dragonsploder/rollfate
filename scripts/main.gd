extends Node

@export var planet : Node
@export var player : Node
@export var camera : Camera2D
@export var ui: Node

var ponderings = 1.0
var planet_scale = 1
const PLAYER_SPEED = 10000
const ROT_SPEED = 2
var is_pondering : bool = false

var do_spawning = false

const WIZARD = preload("uid://dnab7mgo1j34n")
const PLANET = preload("uid://bo1gnnd1wid0e")
const BOLT = preload("uid://c2me2k2weof5b")

var income_angles = [0, PI/2, PI, -PI/2]


var in_towerpit = false
var entering_towerpit = false
var block = false

func get_planet_rot():
	return planet.rotation

func get_towerpit_zoom() -> Vector2:
	var z = 1/get_planet_scale() * 100
	return Vector2(z,z)

func enter_towerpit():
	hide_text_popup()
	entering_towerpit = true
	block = true
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "position", Vector2(0,0), 2.0)
	tween.parallel().tween_property(camera, "rotation", 2*PI+ PI/2, 2.0)
	tween.parallel().tween_property(camera, "zoom", get_towerpit_zoom(), 2.0)
	await tween.finished
	entering_towerpit = false
	in_towerpit = true
	block = false

func get_active_cost(type: int) -> int:
	match type:
		0: return 10 + 5 * get_num_wizards(0)
		1: return 100 + 50 * get_num_wizards(1)
		2: return 1000 + 500 * get_num_wizards(2)
		3: return 1000 + 500 * get_num_wizards(3)
		4: return 1000 + 500 * get_num_wizards(3)
		
	return 100000000
	
func get_pps(type: int) -> int:
	match type:
		0: return 1
		1: return 10
		2: return 100
		3: return 0
		4: return 0
		
	return 1

func _ready() -> void:
	planet_scale = get_planet_scale_raw()
	
func show_text_popup(text: String):
	if not in_towerpit and not entering_towerpit:
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
	
	if ponderings > 1200:
		do_spawning = true
	
	# handel monoliths
	for mono in $Planet/Monoliths.get_children():
		if ponderings >= mono.min_ponderings:
			mono.active = true
			mono.show()
			mono.position = Vector2.from_angle(mono.angle_loc) * planet_scale
			mono.rotation = mono.angle_loc + PI / 2
			for a in mono.get_overlapping_areas():
				if "is_player_area" in a:
					player._on_player_entered(mono)
					break
		else:
			hide_mono_stuff(mono)

	
	# Update stuff
	if block:
		return 
	if in_towerpit:
		camera.zoom = get_towerpit_zoom()
		if Input.is_action_just_pressed("b"):
			block = true
			var tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(camera, "position", player.position, 2.0)
			tween.parallel().tween_property(camera, "rotation", player.rotation, 2.0)
			tween.parallel().tween_property(camera, "zoom", Vector2(1.0,1.0), 2.0)
			await tween.finished
			in_towerpit = false
			block = false
		if Input.is_action_just_pressed("a"):
			for w in $Planet/NavyWizzers.get_children():
				if dec_ponderings(0.01 * ponderings):
					var b = BOLT.instantiate()
					self.add_child(b)
					b.set_yellow()
					b.position = w.global_position
					b.rotation = w.global_rotation
			
			
		if Input.is_action_pressed("l"):
			planet.rotation -= ROT_SPEED * delta
		elif Input.is_action_pressed("r"):
			planet.rotation += ROT_SPEED * delta
		planet.rotation = fmod(planet.rotation, 2 *PI)
	else:
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
		0: $Planet/NoviceMages.add_child(wiz)
		1: $Planet/JournymanMages.add_child(wiz)
		2: $Planet/ElderMages.add_child(wiz)
		3: $Planet/NavyWizzers.add_child(wiz)
		4: $Planet/NavyWizzers.add_child(wiz)
	wiz.set_type(type)

func inc_ponderings(amt: float):
	ponderings += amt

func get_planet_scale_raw() -> float:
	return log(ponderings + 1.0) * 100.0
	
func get_planet_scale() -> float:
	return planet_scale

func get_num_wizards(type) -> int:
	match type:
		0: return len($Planet/NoviceMages.get_children())
		1: return len($Planet/JournymanMages.get_children())
		2: return len($Planet/ElderMages.get_children())
		3: return len($Planet/NavyWizzers.get_children())
		4: return len($Planet/NavyWizzers.get_children())
		
	return 0
	
func get_total_pps() -> float:
	var t = 0.0
	for i in range(0,3):
		t += get_num_wizards(i) * float(get_pps(i))
	return t
	
func _on_addponders_timeout() -> void:
	inc_ponderings(get_total_pps() * 0.1)

func give_back_angle(a: float):
	income_angles.append(a)

func spawn_archplanet():
	var ap = PLANET.instantiate()
	$ArchPlanets.add_child(ap)
	ap.income_angle = income_angles.pick_random()
	income_angles.erase(ap.income_angle)
	ap.set_start()

func _on_spawnarch_timeout() -> void:
	if do_spawning and len($ArchPlanets.get_children()) < 3 and randi_range(0,8) == 0:
		spawn_archplanet()
