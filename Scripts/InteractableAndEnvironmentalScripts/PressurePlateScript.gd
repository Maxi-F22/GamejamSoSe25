extends Area3D

# Implements functionality for detecting the boxes on the pressure plates

@export var _door_control_name: String
var door_unit_object: Node3D
var is_deactivated = false
var cam_switcher
var gitter_sound : AudioStreamPlayer3D
var plate_sound : AudioStreamPlayer3D

func _ready() -> void:
	plate_sound = get_node("PlateSound")
	cam_switcher = get_tree().get_root().get_node("Main/CamSwitcher")
	# correct collision layer and mask for detecting the boxes
	collision_layer = 2
	collision_mask = 2
	area_entered.connect(_on_plate_area_entered)

	var doors = get_tree().get_root().get_node("Main/WorldGridMap/Türen")
	door_unit_object = doors.get_node(_door_control_name)
	gitter_sound = door_unit_object.get_node("GitterSound")
	
func _physics_process(delta: float) -> void:
	if is_deactivated and door_unit_object.position.x > 2:
		door_unit_object.global_position = door_unit_object.global_position + Vector3(-1,0,0) * delta
	else: 
		gitter_sound.stop()

func _on_plate_area_entered(area: Area3D):
	# If box is on top, deactivate door and switch to relevant camera for 3 seconds
	if area.name.contains("BoxArea"):
		is_deactivated = true
		plate_sound.play()
		gitter_sound.play()
		var former_cam_index = cam_switcher.current_cam_index
		var former_cam_icon = cam_switcher.active_cam_icon
		cam_switcher.current_cam_index = 8
		cam_switcher.active_cam_icon = "CameraIcon7"
		await get_tree().create_timer(3.0).timeout
		cam_switcher.current_cam_index = former_cam_index
		cam_switcher.active_cam_icon = former_cam_icon