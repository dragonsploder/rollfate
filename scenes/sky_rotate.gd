extends Node2D

@export var rotate_rate : float

func _process(delta: float) -> void:
	rotation += rotate_rate * delta
