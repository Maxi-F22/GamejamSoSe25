extends Area3D

@export var _door_control_name: String
var door_unit_object: Node3D
var is_deactivated = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 2
	collision_mask = 2
	area_entered.connect(_on_plate_area_entered)

	var doors = get_tree().get_root().get_node("Main/WorldGridMap/Türen")
	door_unit_object = doors.get_node(_door_control_name)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_deactivated and door_unit_object.position.x > 2:
		door_unit_object.global_position = door_unit_object.global_position + Vector3(-1,0,0) * delta

func _on_plate_area_entered(area: Area3D):
	if area.name.contains("BoxArea"):
		is_deactivated = true
