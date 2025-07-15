extends CharacterBody3D

@export var speed: float = 3.0

var cam_switcher
var is_moving = false
var is_active_character = false
var target_position = Vector3(0,0,0)

func _ready():
	cam_switcher = get_tree().get_root().get_node("Main/ExRoom/CamSwitcher")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Move active character towards the position clicked with the mouse
	elif is_on_floor() and is_moving:
		if Vector3(global_position.x, 0, global_position.z).distance_to(target_position) > 0.26:
			# Move toward the target
			var direction = (target_position - global_position)
			direction.y = 0
			direction = direction.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity = Vector3(0,0,0)
			is_moving = false
			
	move_and_slide()
 
func _unhandled_input(event: InputEvent) -> void:
	# Get mouse button input and raycast clicked position on ground
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and is_active_character:
		is_moving = true
		var space_state = get_world_3d().direct_space_state
		var cam = cam_switcher.current_cam
		var mousepos = get_viewport().get_mouse_position()

		var origin = cam.project_ray_origin(mousepos)
		var end = origin + cam.project_ray_normal(mousepos) * 1000
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		if result && result.collider.name == "Ground":
			target_position = result.position
