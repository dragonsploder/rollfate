extends Control

@export var start_volume : float = 0.8
@export var main: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("a"):
		_on_start_pressed()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(main)


func _on_exit_pressed() -> void:
	get_tree().quit()
