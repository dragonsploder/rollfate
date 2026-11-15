extends Area2D

@onready var main_manager = get_tree().current_scene

var speed = 2000.0

var yellow = false

func set_yellow():
	$Sprite2D.play("yellow")
	yellow = true
	
	set_collision_mask_value(3, false)
	set_collision_mask_value(4, true)

func _process(delta: float) -> void:
	self.position += -self.transform.y * delta * speed
	
	if self.position.distance_to(Vector2(0,0)) < main_manager.get_planet_scale() * 0.9 and not yellow:
		self.queue_free()


func _on_timer_timeout() -> void:
	queue_free()

func play_wiz_death():
	$death.play()

var can_kill = true
func _on_area_entered(area: Area2D) -> void:
	if not yellow:
		if can_kill:
			can_kill = false
			area.get_parent().queue_free()
			main_manager.play_wiz_death()
		queue_free()
	else:
		area.hit()
		queue_free()
