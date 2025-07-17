extends Node3D  # Or DirectionalLight3D if it's the light itself

@export var rotation_speed: float = 45.0  # Degrees per second

func _process(delta):
	rotation_degrees.y += rotation_speed * delta
