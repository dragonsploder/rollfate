extends Node2D

@onready var main_manager = get_tree().current_scene

var angle = 0

func _process(delta: float) -> void:
	place_player()
	
	
func place_player():
	# Place player in correct spot
	var planet_scale = main_manager.get_planet_scale()
	
	self.position = Vector2.from_angle(angle) * planet_scale
	self.rotation = angle + PI / 2
	
func walk(amt: float):
	angle += amt 
	place_player()
