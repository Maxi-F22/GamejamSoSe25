extends Node3D

# Implements the Generation of Area3D objects in every cell of gridmap

func _ready() -> void:
	var grid_map = get_node("GridMap")
	var cells = grid_map.get_used_cells()
	for cell in cells:
		create_area_at_cell(grid_map, cell)

func create_area_at_cell(grid_map: GridMap, cell_position: Vector3i):
	var area = Area3D.new()

	# Area should not be detected by raycasting, only by waves
	area.collision_layer = 2
	area.collision_mask = 0
	
	# Set area and collider parameters and add to cell
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	
	collision_shape.shape = box_shape
	area.add_child(collision_shape)

	add_child(area)

	var world_position = grid_map.map_to_local(cell_position)
	area.global_position = grid_map.global_position + world_position

	area.name = "GridMap_" + str(cell_position.x) + "_" + str(cell_position.y) + "_" + str(cell_position.z)
	
