extends Node2D

@onready var main_manager = get_tree().current_scene

var angle = 0

var active_monolith = null

func _process(delta: float) -> void:
	place_player()
	
	if is_instance_valid(active_monolith):
		main_manager.show_text_popup(active_monolith.get_monolith_text())
	
	
func place_player():
	# Place player in correct spot
	var planet_scale = main_manager.get_planet_scale()
	
	self.position = Vector2.from_angle(angle) * planet_scale
	self.rotation = angle + PI / 2
	
func walk(amt: float):
	angle += amt 
	place_player()


func _on_player_entered(area: Area2D) -> void:
	if "active" in area and area.active:
		if area.has_method("get_monolith_text"):
			active_monolith = area
		

func _on_player_exited(area: Area2D) -> void:
	if "active" in area and area.active:
		if area.has_method("get_monolith_text"):
			active_monolith = null
			main_manager.hide_text_popup()
