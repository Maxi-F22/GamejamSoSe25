extends RigidBody3D

# Implements functionality for moving the boxes

@export var push_speed: float = 5.0
@export var grid_size: float = 2.0 # Size of a gridmap cell
var is_being_pushed = false
var target_position = Vector3.ZERO
var grid_map: GridMap
var original_rotation
var original_position
var box_push_sound: AudioStreamPlayer3D
var box_destroy_sound: AudioStreamPlayer3D

func _ready() -> void:
    var box_area = get_node("BoxArea")
    box_push_sound = get_node("PushSound")
    box_destroy_sound = get_node("DestroySound")
    box_area.collision_layer = 2
    box_area.area_entered.connect(_on_box_area_entered)

    original_rotation = global_rotation
    original_position = global_position
    
    # Find gridmap in tree
    grid_map = get_tree().get_root().get_node("Main").find_child("GridMap", true, false)

func _physics_process(delta: float) -> void:
    if is_being_pushed:
        # Move Box to goal position
        global_position = global_position.move_toward(target_position, push_speed * delta)
        global_rotation = original_rotation # keep box always in same rotation

        if global_position.distance_to(target_position) < 0.1:
            global_position = target_position
            
            box_push_sound.stop()
            stop_pushing()

func _on_box_area_entered(area):
	# If character is Heavy, move box in opposite direction of player
    if area.name.contains("MassWave") and not is_being_pushed:
        var player = area.get_parent().get_parent()
        push_until_wall(player)
        box_push_sound.play()
    # If character is Schall or move into Laser, destroy box
    if area.name.contains("ScreamWave"):
        reset_position()
    if area.name.contains("LaserArea"):
        reset_position()

func push_until_wall(player: Node3D):
    is_being_pushed = true
    freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
    
    var raw_direction = (global_position - player.global_position).normalized()
    raw_direction.y = 0
    var push_direction = get_cardinal_direction(raw_direction)
    target_position = find_wall_stop_position(push_direction)

func find_wall_stop_position(direction: Vector3):
    # Find next gridmap wall cell in direction
    var current_pos = global_position
    var check_distance = grid_size
    
    # Check for every cell in range if wall is there
    for i in range(1, 20):
        var test_position = current_pos + direction * (check_distance * i)
        var grid_pos = world_to_grid(test_position)
        if is_wall_at_grid(grid_pos):
            # If wall found, stop before it
            var stop_position = current_pos + direction * (check_distance * (i-1))
            return stop_position
    
    return current_pos + direction * check_distance

func world_to_grid(world_pos: Vector3):
    # convert world coordinates to gridmap coordinates
    return grid_map.local_to_map(grid_map.to_local(world_pos))

func is_wall_at_grid(grid_pos: Vector3i):
    var cell_item = grid_map.get_cell_item(grid_pos)
    return cell_item != GridMap.INVALID_CELL_ITEM

func get_cardinal_direction(direction: Vector3):
    # convert the direction to cardinal directions
    if abs(direction.x) > abs(direction.z):
        if direction.x > 0:
            return Vector3(1, 0, 0) # Right
        else:
            return Vector3(-1, 0, 0) # Left
    else:
        if direction.z > 0:
            return Vector3(0, 0, 1) # Forward
        else:
            return Vector3(0, 0, -1) # Backwards

func stop_pushing():
    is_being_pushed = false
    freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func reset_position():
    global_position = original_position
    box_destroy_sound.play()
    box_push_sound.stop()
    stop_pushing()