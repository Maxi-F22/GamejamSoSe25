extends Area3D

@export var _glass_control_name: String
var glass_unit_object: Area3D
var is_deactivated = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 2
	area_entered.connect(_on_glass_area_entered)

	#var grid_map = get_tree().get_root().get_node("Main/WorldGridMap")
	#glass_unit_object = grid_map.get_area(_glass_control_name)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if is_deactivated:
		print("Glass kaputt kurwa")
		queue_free()
		

func _on_glass_area_entered(area: Area3D):
	if area.name.contains("Druckwelle"):
		is_deactivated = true
