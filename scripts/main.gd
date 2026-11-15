extends Node

@export var planet : Node
@export var player : Node
@export var camera : Camera2D
@export var ui: Node

var ponderings = 1.0
var planet_scale = 1
const PLAYER_SPEED = 5000
const ROT_SPEED = 0.75
var is_pondering : bool = false

var fire_cool_down = -0.5
var fire_cool_down_time = 0.5

var do_spawning = false
var ponder_speed_rhythm = 1
var player_pondering_scale = 1


const WIZARD = preload("uid://dnab7mgo1j34n")
const PLANET = preload("uid://bo1gnnd1wid0e")
const BOLT = preload("uid://c2me2k2weof5b")

var income_angles = [0, PI/2, PI, -PI/2, PI/4, 3*PI/4, -PI/4, -3*PI/4]

var novice_wizard_mult = 1.0
var journyman_wizard_mult = 1.0
var elder_wizard_mult = 1.0


var in_towerpit = false
var entering_towerpit = false
var block = false
var do_spin = true

const TREE_2 = preload("uid://dp5oeo8a81vj0")

const THINK_1 = preload("uid://csq887qihfyuj")
const THINK_2 = preload("uid://btspcw41f56u5")
const THINK_3 = preload("uid://c81crds12fvca")
const THINK_4 = preload("uid://b03p6xuxekwkg")
const THINK_5 = preload("uid://ckhh53v57bqvh")
const THINK_6 = preload("uid://c731sumq8ugj3")
const THINK_7 = preload("uid://d8j08s7brl7b")
const THINK_8 = preload("uid://duwbpkfm8tdxr")
const THINK_9 = preload("uid://c4gn4iyhtb24i")

var think_sounds = [
	THINK_1,
	THINK_2,
	THINK_3,
	THINK_4,
	THINK_5,
	THINK_6,
	THINK_7,
	THINK_8,
	THINK_9,
]

const NOV_READ = preload("uid://bsqh71tq3hnvt")
const JOURNY_READ = preload("uid://dy7tuyd8dinee")
const ELDER_READ = preload("uid://che1qfji7bvod")
const ZAPER_READ = preload("uid://tyjcidk427qc")

var winning = false
var planet_difficulty = 1

var seen_mono = []

static func add_commas(number):
	number = int(number)

	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	return res

func get_planet_rot():
	return planet.rotation

func get_towerpit_zoom() -> Vector2:
	var z = 1/get_planet_scale() * 100
	#var z = 1/get_planet_scale() * 150
	return Vector2(z,z)

func enter_towerpit():
	$towerpitup.play()
	hide_text_popup()
	entering_towerpit = true
	block = true
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if do_spin:
		tween.tween_property(camera, "position", Vector2(0,0), 0.8)
		tween.parallel().tween_property(camera, "rotation", 2*PI+ PI/2, 0.8)
		tween.parallel().tween_property(camera, "zoom", get_towerpit_zoom(), 0.8)
	else:
		tween.tween_property(camera, "position", Vector2(0,0), 0.8)
		tween.parallel().tween_property(camera, "rotation", PI/2, 0.8)
		tween.parallel().tween_property(camera, "zoom", get_towerpit_zoom(), 0.8)

	await tween.finished
	entering_towerpit = false
	in_towerpit = true
	block = false

func get_active_cost(type: int) -> int:
	match type:
		0: return 77 + 6.0 * pow(1.5 * get_num_wizards(0), 2)
		1: return 3300 + 80 * pow(2 * get_num_wizards(1), 2)
		2: return 120_000 + 50_000 * pow(3*get_num_wizards(2),2)
		
		3: return 10_000 + 500 * pow(get_num_wizards(3), 1.5)
		4: return 10_000 + 500 * pow(get_num_wizards(3), 1.5)
		
	return 10000000000
	
func get_pps(type: int) -> int:
	match type:
		0: return 4 * novice_wizard_mult
		1: return 60 * journyman_wizard_mult
		2: return 2_000 * elder_wizard_mult
		3: return 0
		4: return 0
		
	return 1

func get_current_focus_base_pps():
	if is_pondering:
		return planet.ponder_income
	else:
		return 0

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
	if winning:
		return
	
	fire_cool_down -= delta
	planet_scale = lerp(float(planet_scale), get_planet_scale_raw(), 0.99 * delta)
	
	if ponderings > 10_000 and not do_spawning:
		do_spawning = true
		_on_spawnarch_timeout()
		
	if ponderings > 100_000 and planet_difficulty == 1:
		planet_difficulty = 3
	#if ponderings > 100000 and planet_difficulty == 2:
	#	planet_difficulty = 3
	
	# handle monoliths
	for mono in $Planet/Monoliths.get_children():
		if ponderings >= mono.min_ponderings:
			mono.active = true
			mono.show()
			if not mono.type in seen_mono:
				seen_mono.append(mono.type)
				$newmono.play()
				
		mono.position = Vector2.from_angle(mono.angle_loc) * planet_scale
		mono.rotation = mono.angle_loc + PI / 2
			
			
		for a in mono.get_overlapping_areas():
			if "is_player_area" in a:
				player._on_player_entered(mono)
				break
		#else:
			#hide_mono_stuff(mono)
		#	pass

	
	# Update stuff
	if block:
		return 
	if is_pondering:
		planet.continue_ponder(delta)
	if in_towerpit:
		camera.zoom = get_towerpit_zoom()
		if Input.is_action_just_pressed("b"):
			$towerpitdown.play()
			block = true
			var tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

			if do_spin:
				tween.tween_property(camera, "position", player.position, 0.8)
				tween.parallel().tween_property(camera, "rotation", player.rotation, 0.8)
				tween.parallel().tween_property(camera, "zoom", Vector2(1.0,1.0), 0.8)
				do_spin = false
			else:
				camera.rotation = fmod(camera.rotation, 2 *PI)
				tween.tween_property(camera, "position", player.position, 0.8)
				tween.parallel().tween_property(camera, "rotation", player.rotation, 0.8)
				tween.parallel().tween_property(camera, "zoom", Vector2(1.0,1.0), 0.8)
			
			await tween.finished
			in_towerpit = false
			block = false
		if Input.is_action_pressed("a"):
			if fire_cool_down < 0.0:
				if len($Planet/NavyWizzers.get_children()) > 0:
					$shoot.play()
				for w in $Planet/NavyWizzers.get_children():
					if dec_ponderings(0.01 * ponderings):
						var b = BOLT.instantiate()
						self.add_child(b)
						b.set_yellow()
						b.position = w.global_position
						b.rotation = w.global_rotation
				fire_cool_down = fire_cool_down_time
			
			
		if Input.is_action_pressed("l"):
			planet.rotation -= ROT_SPEED * delta
		elif Input.is_action_pressed("r"):
			planet.rotation += ROT_SPEED * delta
		planet.rotation = fmod(planet.rotation, 2 *PI)
	else:
		if Input.is_action_just_pressed("a"):
			if is_instance_valid(player.active_monolith):
				player.active_monolith.attempt_active_monolith()
			elif (not is_pondering):
				planet.start_pondering()
				is_pondering = true
			
		elif (Input.is_action_just_released("a") and is_pondering):
			is_pondering = false
			planet.stop_pondering()
	
		var rad_dist = PLAYER_SPEED / (2 * PI * get_planet_scale())
		if Input.is_action_pressed("l") and not is_pondering:
			player.walk(-delta * rad_dist)
			player.left()
		elif Input.is_action_pressed("r") and not is_pondering:
			player.walk(delta * rad_dist)
			player.right()
		elif Input.is_action_just_pressed("b"):
			# We use the b button to try and actively sync the ponder to the ryhthm of the rings
			if (is_pondering):
				if (not planet.ponder()):
					is_pondering = false
			else:
				$PauseMenu.can_unpause = false
				$PauseMenu.double_check = false
				$PauseMenu.show()
				get_tree().paused = true
			
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
		0: 
			$Planet/NoviceMages.add_child(wiz) 
			$spawn.stream = NOV_READ
		1: 
			$Planet/JournymanMages.add_child(wiz)
			$spawn.stream = JOURNY_READ
		2: 
			$Planet/ElderMages.add_child(wiz)
			$spawn.stream = ELDER_READ
		3: 
			$Planet/NavyWizzers.add_child(wiz)
			$spawn.stream = ZAPER_READ
		4: 
			$Planet/NavyWizzers.add_child(wiz)
			$spawn.stream =ZAPER_READ
		9:
			$Planet/trees.add_child(wiz)
			$spawn.stream =null
			
	wiz.set_type(type)
	$wizspawn.play()
	$spawn.play()

func inc_ponderings(amt: float):
	ponderings += amt

func get_planet_scale_raw() -> float:
	#return log(ponderings + 1.0) * 100.0
	return log(ponderings + 3.0) * 85.0
	
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
	ap.set_difficulty(planet_difficulty)

func _on_spawnarch_timeout() -> void:
	if do_spawning and not (ponderings < 10_000 and get_num_wizards(4) == 0):
		var to_spawn = randi_range(1,3)
		var t = min(to_spawn, 5 - len($ArchPlanets.get_children()))
		for i in range(t):
			print("spawn_planet")
			spawn_archplanet()
	#if do_spawning and len($ArchPlanets.get_children()) < 5 and randi_range(0,2 + int(len($ArchPlanets.get_children())/2)) == 0:
	#	spawn_archplanet()

func give_upgrade_1(idx):
	match idx:
		0: novice_wizard_mult *= 2.0
		1: novice_wizard_mult *= 2.0
		2: journyman_wizard_mult *= 2.0
		3: novice_wizard_mult *= 10
		4: journyman_wizard_mult *= 5.0

func on_planet_death():
	$planetDeath.play()

func give_upgrade_2(idx):
	match idx:
		0: planet.ponder_income *= 4
		1: planet.ponder_income *= 6
		2: planet.ponder_income *= 7
		3: fire_cool_down_time /= 2.0
		4: planet.ponder_income *= 20

func play_wiz_death():
	$death.play()

func win():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	ui.win()
	winning = true
	
func get_buttons_context():
	if is_pondering:
		return "Release Z: Stop Pondering | X : Focuse Ponder Beat"
	
	if in_towerpit:
		return "Z: Order a Zap | X : Exit towerpit | Arrow Keys: Rotate"
		
	if is_instance_valid(player.active_monolith):
		return "Z : Activate Monolith | X : Pause | Arrow Keys: Walk"

	return "Z : Ponder | X : Pause | Arrow Keys: Walk"
