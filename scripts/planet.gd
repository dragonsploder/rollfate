extends Node2D

@onready var main_manager = get_tree().current_scene

var x_len = 0

func _ready() -> void:
	x_len = $Marker2D.position.x

func _process(delta: float) -> void:
	var target_scale = main_manager.get_planet_scale()
	
	var true_scale = target_scale / x_len
	
	self.scale = Vector2(true_scale, true_scale)
