extends Node3D

# Rotates the red lights

@export var rotation_speed: float = 45.0  # Degrees per second

func _process(delta):
	rotation_degrees.y += rotation_speed * delta
