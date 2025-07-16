extends RigidBody3D

@export var push_speed: float = 5.0
@export var grid_size: float = 2.0  # Größe einer GridMap-Zelle
var is_being_pushed = false
var target_position = Vector3.ZERO
var grid_map: GridMap
var original_rotation

func _ready() -> void:
    var box_area = get_node("BoxArea")
    box_area.collision_layer = 2
    box_area.area_entered.connect(_on_box_area_entered)

    original_rotation = global_rotation
    
    # Finde GridMap
    grid_map = find_gridmap()

func find_gridmap() -> GridMap:
    var main = get_tree().get_root().get_node("Main")
    return main.find_child("GridMap", true, false)

func _physics_process(delta: float) -> void:
    if is_being_pushed:
        # Bewege Box zur Zielposition
        global_position = global_position.move_toward(target_position, push_speed * delta)
        global_rotation = original_rotation
        # Stoppe wenn Ziel erreicht
        if global_position.distance_to(target_position) < 0.1:
            global_position = target_position
            stop_pushing()

func _on_box_area_entered(area):
    if area.name.contains("MassWave") and not is_being_pushed:
        var player = area.get_parent().get_parent()
        push_until_wall(player)

func push_until_wall(player: Node3D):
    is_being_pushed = true
    freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
    
    # Berechne Richtung
    var raw_direction = (global_position - player.global_position).normalized()
    raw_direction.y = 0
    var push_direction = get_cardinal_direction(raw_direction)
    
    # Finde Position vor der nächsten Wand
    target_position = find_wall_stop_position(push_direction)
    
    print("Pushing box to wall stop at: ", target_position)

func find_wall_stop_position(direction: Vector3) -> Vector3:
    if not grid_map:
        return global_position + direction * grid_size  # Fallback
    
    var current_pos = global_position
    var check_distance = grid_size
    
    # Prüfe schrittweise in Richtung bis Wand gefunden
    for i in range(1, 20):  # Max 20 Zellen weit schauen
        var test_position = current_pos + direction * (check_distance * i)
        var grid_pos = world_to_grid(test_position)
        
        # Prüfe ob an dieser Position eine Wand ist
        if is_wall_at_grid(grid_pos):
            # Wand gefunden - gehe einen Schritt zurück
            var stop_position = current_pos + direction * (check_distance * (i-1))
            return stop_position
    
    # Keine Wand gefunden - bewege nur eine Zelle
    return current_pos + direction * check_distance

func world_to_grid(world_pos: Vector3) -> Vector3i:
    if not grid_map:
        return Vector3i.ZERO
    return grid_map.local_to_map(grid_map.to_local(world_pos))

func is_wall_at_grid(grid_pos: Vector3i) -> bool:
    if not grid_map:
        return false
    
    var cell_item = grid_map.get_cell_item(grid_pos)
    return cell_item != GridMap.INVALID_CELL_ITEM  # Wand wenn Zelle belegt

func get_cardinal_direction(direction: Vector3) -> Vector3:
    if abs(direction.x) > abs(direction.z):
        if direction.x > 0:
            return Vector3(1, 0, 0)   # Rechts
        else:
            return Vector3(-1, 0, 0)  # Links
    else:
        if direction.z > 0:
            return Vector3(0, 0, 1)   # Vorwärts
        else:
            return Vector3(0, 0, -1)  # Rückwärts

func stop_pushing():
    is_being_pushed = false
    freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
    print("Box stopped at: ", global_position)