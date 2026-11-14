extends Node2D

@onready var main_manager = get_tree().current_scene

@export var is_player = false

var x_len = 0

var radius_mod = 1.0

var income_angle = 0

func set_start() -> void:
	self.position =  Vector2.from_angle(income_angle) * main_manager.get_planet_scale() * 8

func _ready() -> void:
	x_len = $Marker2D.position.x
	
	if not is_player:
		radius_mod += randf_range(-0.3, -0.1)
		
	var target_scale = main_manager.get_planet_scale() * radius_mod
	var true_scale = target_scale / x_len
	self.scale = Vector2(true_scale, true_scale)
	

func _process(delta: float) -> void:
	if not is_player:
		var target_position =  Vector2.from_angle(income_angle) * main_manager.get_planet_scale() * 3
		self.position = lerp(self.position, target_position, delta * 0.1)
		
		return
		
		
	var target_scale = main_manager.get_planet_scale() * radius_mod
	

	var true_scale = target_scale / x_len
	
	self.scale = Vector2(true_scale, true_scale)
