extends CharacterBody3D

# Implements character movement control

@export var mouse_arrow = preload("res://Scenes/CharacterPrefabs/WavePrefabs/waypoint.tscn")
@export var speed: float = 5.0
@onready var _player_model: = $PlayerModel  as Node3D

var cam_switcher
var is_moving = false
var allow_movement = true
var is_active_character = false
var target_position = Vector3(0,0,0)
var player_anim_player : AnimationPlayer
var active_arrow_instance = null

var position_check_timer = 0.0
var position_check_interval = 0.5
var last_position = Vector3.ZERO

func _ready():
	cam_switcher = get_tree().get_root().get_node("Main/CamSwitcher")
	player_anim_player = _player_model.get_node("AnimationPlayer")
	play_animation("idle")

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Move active character towards the position clicked with the mouse
	elif is_on_floor() and is_moving:
		if Vector3(global_position.x, 0, global_position.z).distance_to(target_position) > 2.01 and allow_movement:
			play_animation("walking")
			# Move toward the target
			var direction = (target_position - global_position)
			direction.y = 0
			direction = direction.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			var target_rot = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rot, 0.15)
		else:
			velocity = Vector3(0,0,0)
			is_moving = false

	if not player_anim_player.is_playing():
		play_animation("idle")

	check_if_stuck(delta)

	move_and_slide()
 
func _unhandled_input(event: InputEvent) -> void:
	# Get mouse button input and raycast clicked position on ground
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and is_active_character:
		var space_state = get_world_3d().direct_space_state
		var cam = cam_switcher.current_cam
		var mousepos = get_viewport().get_mouse_position()

		var origin = cam.project_ray_origin(mousepos)
		var end = origin + cam.project_ray_normal(mousepos) * 1000
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collision_mask = 1
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		if result && result.collider.name == "GridMap":
			is_moving = true
			target_position = result.position
			spawn_mouse_arrow(result.position)

func play_animation(anim_name):
	player_anim_player.play(anim_name)

func spawn_mouse_arrow(mouse_position: Vector3):
	# Instantiate the mouse_arrow scene according to raycast position
	if active_arrow_instance != null and is_instance_valid(active_arrow_instance):
		active_arrow_instance.queue_free()
	
	active_arrow_instance = mouse_arrow.instantiate()
	get_tree().current_scene.add_child(active_arrow_instance)
	
	active_arrow_instance.global_position = mouse_position + Vector3(0, 0, 0)
	active_arrow_instance.scale = Vector3(0.2,0.2,0.2)

	var arrow_anim_player = active_arrow_instance.get_node("AnimationPlayer")
	arrow_anim_player.stop()
	arrow_anim_player.seek(0.0)
	
	await get_tree().process_frame
	
	arrow_anim_player.play("CubeAction")
	await get_tree().create_timer(3.0).timeout

	if is_instance_valid(active_arrow_instance):
		active_arrow_instance.queue_free()

func check_if_stuck(delta: float):
	# Check if character is stuck in walk animation due to running into wall or other character
	position_check_timer += delta

	# If character hasn't moved in 1 second, set animation to idle	
	if position_check_timer >= 1.0:
		var distance_moved = global_position.distance_to(last_position)

		if is_moving and distance_moved < 0.1:
			is_moving = false
			velocity = Vector3.ZERO
			play_animation("idle")
		
		last_position = global_position
		position_check_timer = 0.0
