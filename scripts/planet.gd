extends Area2D

@onready var main_manager = get_tree().current_scene

@export var is_player = false

var x_len = 0

var radius_mod = 1.0

var income_angle = 0
var this_planet_scale = Vector2(1.0,1.0)

var hp = 20

const BOLT = preload("uid://c2me2k2weof5b")
const ARCH_ORB = preload("uid://bnomjs570alyk")

func set_start() -> void:
	self.position =  Vector2.from_angle(income_angle) * main_manager.get_planet_scale() * 8

func _ready() -> void:
	x_len = $Marker2D.position.x
	
	if not is_player:
		radius_mod += randf_range(-0.3, -0.1)
		$PlanetSprite.texture = ARCH_ORB
	else:
		set_collision_layer_value(4, false)

		
	this_planet_scale = main_manager.get_planet_scale() * radius_mod
	var true_scale = this_planet_scale / x_len
	self.scale = Vector2(true_scale, true_scale)
	

func _process(delta: float) -> void:
	if not is_player:
		var target_position =  Vector2.from_angle(income_angle) * main_manager.get_planet_scale() * 3
		self.position = lerp(self.position, target_position, delta * 0.1)
		
		if self.position.distance_to(target_position) < main_manager.get_planet_scale() * 4  and $Zap.is_stopped():
			$Zap.start()
			
		
		
		# Move wizard
		$Wiz.position = self.position + Vector2.from_angle(PI + income_angle) * this_planet_scale
		$Wiz.rotation = -PI/2 + income_angle
		$Wiz.show()
			
		if hp <= 0:
			main_manager.give_back_angle(income_angle)
			queue_free()
		return
		
		
	var target_scale = main_manager.get_planet_scale() * radius_mod
	

	var true_scale = target_scale / x_len
	
	self.scale = Vector2(true_scale, true_scale)


func begin_pondering():
	pass		
	


func clear_pondering():
	pass	

func hit():
	hp -= 1


func _on_zap_timeout() -> void:
	var b = BOLT.instantiate()
	self.add_child(b)
	b.position = $Wiz.position
	b.rotation = $Wiz.rotation + randf_range(-0.15, 0.15)
	
