extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get GridMap reference
	var grid_map = get_node("GridMap")
	var cells = grid_map.get_used_cells()
	for cell in cells:
		create_area_at_cell(grid_map, cell)

func create_area_at_cell(grid_map: GridMap, cell_position: Vector3i):
	# Erstelle neue Area3D
	var area = Area3D.new()
	# Area should not be detected by raycasting, only by waves
	area.collision_layer = 2
	area.collision_mask = 0
    
	# Erstelle CollisionShape3D
	var collision_shape = CollisionShape3D.new()
    
	# Erstelle BoxShape3D
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)  # Größe der GridMap-Zelle
    
	# Verbinde Shape mit CollisionShape
	collision_shape.shape = box_shape
    
	# Füge CollisionShape zur Area hinzu
	area.add_child(collision_shape)

	# Füge Area zur Szene hinzu (als Child von diesem Node)
	add_child(area)
    
	# Berechne Weltposition der Zelle
	var world_position = grid_map.map_to_local(cell_position)
	area.global_position = grid_map.global_position + world_position
    
	# Name für debugging
	area.name = "GridMap_" + str(cell_position.x) + "_" + str(cell_position.y) + "_" + str(cell_position.z)
    