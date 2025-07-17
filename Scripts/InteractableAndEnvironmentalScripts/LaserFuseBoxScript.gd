extends Area3D

# Implements functionality for fuse box and laser wall

@export var _laser_control_name: String #Laser Wall object to move
var laser_unit_object: Node3D
var is_deactivated = false
var cam_switcher

func _ready() -> void:
	cam_switcher = get_tree().get_root().get_node("Main/CamSwitcher")
	collision_layer = 2 # correct collision layer for detecting the player waves
	area_entered.connect(_on_fuse_area_entered)

	var grid_map = get_tree().get_root().get_node("Main/WorldGridMap")
	laser_unit_object = grid_map.get_node(_laser_control_name)

func _physics_process(delta: float) -> void:
	if is_deactivated:
		laser_unit_object.global_position = laser_unit_object.global_position + Vector3(0,-1,0) * delta

func _on_fuse_area_entered(area: Area3D):
	# If character is Elektro, deactivate laser and switch to relevant camera for 4 seconds
	if area.name.contains("ElektroWave") and not is_deactivated:
		is_deactivated = true
		var former_cam_index = cam_switcher.current_cam_index
		var former_cam_icon = cam_switcher.active_cam_icon
		if name == "LaserBox1":
			cam_switcher.current_cam_index = 2
			cam_switcher.active_cam_icon = "CameraIcon3"
		else:
			cam_switcher.current_cam_index = 7
			cam_switcher.active_cam_icon = "CameraIcon8"
		await get_tree().create_timer(4.0).timeout
		cam_switcher.current_cam_index = former_cam_index
		cam_switcher.active_cam_icon = former_cam_icon
