extends Area2D

@onready var main_manager = get_tree().current_scene
@onready var ring_count = $PonderRings.get_child_count()

@export var is_player = false

var x_len = 0
var radius_mod = 1.0

var income_angle = 0
var this_planet_scale = Vector2(1.0,1.0)

var bounce = 0.0

var hp = 20

var difficulty = 1.0

var ponder_success_radius = 75
var ponder_bonus = 8
var ponder_income = 1
var ponder_vol_mod = 0.6

const BOLT = preload("uid://c2me2k2weof5b")
const ARCH_ORB = preload("uid://bnomjs570alyk")

func set_start() -> void:
	self.position =  Vector2.from_angle(income_angle) * main_manager.get_planet_scale() * 8

func set_difficulty(d):
	difficulty = d
	hp *= d
	$Zap.wait_time /= d

func _ready() -> void:
	x_len = $Marker2D.position.x
	
	if not is_player:
		match randi_range(0,2):
			0: 
				radius_mod -= 0.1
				hp = 12
			1: 
				radius_mod -= 0.4
				hp = 8
			2: 
				radius_mod -= 0.75
				hp = 4
		$PlanetSprite.texture = ARCH_ORB
	else:
		set_collision_layer_value(4, false)

		
	this_planet_scale = main_manager.get_planet_scale() * radius_mod
	var true_scale = this_planet_scale / x_len
	self.scale = Vector2(true_scale, true_scale)
	

func _process(delta: float) -> void:
	
	if not is_player:
		if bounce > 0.0:
			bounce -= delta * 0.35
		var target_position =  Vector2.from_angle(income_angle) * main_manager.get_planet_scale() * (3+bounce)
		self.position = lerp(self.position, target_position, delta * 0.2)
		
		if self.position.distance_to(Vector2(0,0)) < main_manager.get_planet_scale() * 3.5:
			$PlanetSprite.set_modulate(Color(1,1,1))
			if $Zap.is_stopped():
				$Zap.start()
		else:
			$PlanetSprite.set_modulate(Color(0.8,0.8,0.8))
			$Zap.stop()
		
		
		# Move wizard
		$Wiz.position = self.position + Vector2.from_angle(PI + income_angle) * this_planet_scale
		$Wiz.rotation = -PI/2 + income_angle
		$Wiz.show()
			
		if hp <= 0:
			main_manager.give_back_angle(income_angle)
			main_manager.on_planet_death()
			queue_free()
		return
		
	var target_scale = main_manager.get_planet_scale() * radius_mod
	
	var true_scale = target_scale / x_len
	
	self.scale = Vector2(true_scale, true_scale)
	
	var ponder_scale = ($PlanetSprite.get_rect().size.x * scale.x - ponder_success_radius) / $PlanetSprite.get_rect().size.x 
	$"../PonderBarrier".scale = Vector2(ponder_scale, ponder_scale)

# if the outer ring is at the outer radius of the planet, you get a bonus! otherwise kicked out
func ponder():
	var none_in_range = true
	var i = -1
	for idx in range(ring_count):
		if (get_radius() - $PonderRings.get_child(idx).get_radius() < ponder_success_radius):
			none_in_range = false
			if ($PonderRings.get_child(idx).get_radius() > $PonderRings.get_child(i).get_radius()):
				i = idx

	if (none_in_range):
		stop_pondering()
		$FailState.play("fail_ponder_animation")
		$PonderBad.play()
		return false
	else:
		main_manager.inc_ponderings(ponder_bonus * ponder_income)
		$PonderRings.get_child(i).cull()
		$PonderGood.stream = main_manager.bell_sounds.pick_random()
		$PonderGood.play()
		return true

func get_radius():
	return ($PlanetSprite.get_rect().size.x / 2) * scale.x

func start_pondering():
	var next_delay = 0
	for idx in range(ring_count):
		var ring = $PonderRings.get_child(idx)
		ring.begin_grow(next_delay)
		next_delay = ring.get_next_ring_step()
		
	# add some 'focusing' effects to the camera and audio
	var vol = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), vol * ponder_vol_mod)
	$"../PonderUi".show()
	$"../PonderBarrier".visible = true

# the passive ponderings you can get just from being active
func continue_ponder(delta : float):
	main_manager.inc_ponderings(ponder_income * delta)

func stop_pondering():
	for idx in range(ring_count):
		$PonderRings.get_child(idx).reset()
		
	# return our focused effects to normal
	var vol = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), vol / ponder_vol_mod)
	$"../PonderUi".hide()
	$"../PonderBarrier".visible = false

func hit():
	hp -= 1
	$hit.play()
	if bounce < (2.5 / difficulty):
		bounce += 0.5 / difficulty


func _on_zap_timeout() -> void:
	var b = BOLT.instantiate()
	self.add_child(b)
	b.position = $Wiz.position
	b.rotation = $Wiz.rotation + randf_range(-0.15, 0.15)
	$Zapsound.play()
	$Zap.stop()
