extends Control

@export var start_volume : float = 0.8
@export var main: PackedScene

func _on_start_pressed() -> void:
	pass
	get_tree().change_scene_to_packed(main)


func _on_exit_pressed() -> void:
	get_tree().quit()
