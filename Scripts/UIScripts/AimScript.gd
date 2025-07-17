extends Node3D

@onready var _aimer_mesh := $AimerMesh as MeshInstance3D

@export var orbit_radius: float = 3.0
@export var char_script: CharacterBody3D
var wave_area : Area3D
var cam_switcher
var current_cam: Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	cam_switcher = get_tree().get_root().get_node("Main/CamSwitcher")
	wave_area = $SingleWave.get_child(0)
	_aimer_mesh.visible = false
	if wave_area.visible:
		wave_area.visible = false

func _process(_delta):
	if not char_script.is_active_character:
		_aimer_mesh.visible = false
		return
	#_aimer_mesh.visible = true
	current_cam = cam_switcher.current_cam
	if wave_area.visible or not char_script.allow_movement or char_script.is_moving:
		return
	var mouse_pos = get_viewport().get_mouse_position()
	var from = current_cam.project_ray_origin(mouse_pos)
	var to = from + current_cam.project_ray_normal(mouse_pos) * 1000.0

	var ray = PhysicsRayQueryParameters3D.create(from, to)
	var hit = get_world_3d().direct_space_state.intersect_ray(ray)

	if hit:
		var player_pos = char_script.global_position
		var hit_pos = hit.position

		var direction = (hit_pos - player_pos)
		direction.y = 0
		direction = direction.normalized()

		# Position arrow on orbit
		global_position = player_pos + direction * orbit_radius

		var target_rot = atan2(direction.x, direction.z)
		char_script.rotation.y = target_rot

		# Rotate arrow to face AWAY from the player
		look_at(global_position + direction, Vector3.UP)
		rotate_y(deg_to_rad(180))
