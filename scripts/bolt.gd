extends Area2D

@onready var main_manager = get_tree().current_scene

var speed = 2000.0

func _process(delta: float) -> void:
	self.position += -self.transform.y * delta * speed
	
	if self.position.distance_to(Vector2(0,0)) < main_manager.get_planet_scale() * 0.9:
		self.queue_free()


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	area.get_parent().queue_free()
	queue_free()
