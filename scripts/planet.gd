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

# if the outer ring is at the outer radius of the planet, you get a bonus! else, 
func ponder(ponder_bonus : float):
	for idx in range(ring_count):
		if (abs(scale.x - $PonderRings.get_child(idx).scale.x) < 1):
			main_manager.inc_ponderings(ponder_bonus)
			$PonderRings.get_child(idx).scale = Vector2(0.5, 0.5)
			print("good ponder!")
			return true
	stop_pondering()
	return false

func start_pondering():
	for idx in range(ring_count):
		$PonderRings.get_child(idx).visible = true

# we just want to update the rings of the 
func continue_ponder(speed : float, ponder_income : float):
	main_manager.inc_ponderings(ponder_income)
		
	for idx in range(ring_count):
		if (scale.x < $PonderRings.get_child(idx).scale.x):
			$PonderRings.get_child(idx).scale = Vector2(0.5, 0.5)
		else:
			$PonderRings.get_child(idx).scale += Vector2(speed, speed)

func stop_pondering():
	for idx in range(ring_count):
		$PonderRings.get_child(idx).scale = Vector2(0.5, 0.5)
		$PonderRings.get_child(idx).visible = false

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
