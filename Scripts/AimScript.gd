extends Node3D

@export var orbit_radius: float = 3.0
@export var rotation_sensitivity: float = 0.01  # Adjust how fast the rotation reacts to mouse

var current_angle: float = 0.0
var target_position: Vector3

func _ready():
	# Place the arrow at the orbit radius
	$AimerMesh.position = Vector3(orbit_radius, 0, 0)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Mouse motion left/right rotates the aimer
		current_angle -= event.relative.x * rotation_sensitivity

func _process(delta):
	# Update pivot rotation around Y axis (up)
	rotation.y = current_angle
