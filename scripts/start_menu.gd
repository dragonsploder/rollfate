extends Control

@export var start_volume : float = 0.8


@onready var volume_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VolumeSlider


func _ready() -> void:
	volume_slider.value = start_volume
	_on_volume_slider_value_changed(start_volume)


func _on_start_pressed() -> void:
	pass # Replace with function body.

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_exit_pressed() -> void:
	get_tree().quit()
