extends Node3D

@export var orbit_radius: float = 3.0
var camera: Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera = get_viewport().get_camera_3d()
	if not camera:
		push_error("Camera3D not found.")

func _process(_delta):
	if not camera or $SingleWave.get_child(0).visible:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var ray = PhysicsRayQueryParameters3D.create(from, to)
	var hit = get_world_3d().direct_space_state.intersect_ray(ray)

	if hit:
		var player_pos = get_parent().global_position
		var hit_pos = hit.position

		var direction = (hit_pos - player_pos)
		direction.y = 0
		direction = direction.normalized()

		# Position arrow on orbit
		global_position = player_pos + direction * orbit_radius

		# Rotate arrow to face AWAY from the player
		look_at(global_position + direction, Vector3.UP)
		rotate_y(deg_to_rad(180))
