extends Node3D

# Implements the wave logic and animations

@export var electro_throw_scene  = preload("res://Scenes/CharacterPrefabs/WavePrefabs/electro_throw.tscn")
@export var electro_hit_scene= preload("res://Scenes/CharacterPrefabs/WavePrefabs/electro_aufprall.tscn")
@export var screamo_throw_scene = preload("res://Scenes/CharacterPrefabs/woman_scream.tscn")
@export var scale_speed: float = 1
@export var max_scale: float = 3
@export var char_script: CharacterBody3D
@export var is_single: bool = false
var jump_sound: AudioStreamPlayer3D
var projectile_sound: AudioStreamPlayer3D
var scream_sound: AudioStreamPlayer3D

var wave_triggered = false
var is_activating = false
var waves = []
var hit_effect_duration: float = 1.0
var hit_effect_scale: float = 1.0
var throw_speed: float = 10.0
var active_throw_effects = []
var stop_throw = false

func _ready():
	if char_script.name == "Elektro":
		projectile_sound = char_script.get_node("ProjectileSound")
	elif char_script.name == "Heavy":
		jump_sound = char_script.get_node("JumpSound")
	elif char_script.name == "Screamo":
		scream_sound = char_script.get_node("ScreamSound")
		
	for child in get_children():	
		waves.append(child)

	for wave in waves:
		wave.collision_mask = 2 # Set correct collision layer for detecting interactables and walls
		if wave is Area3D:
			wave.area_entered.connect(_on_area_entered.bind(wave))
		# Disable wave objects on start
		for child in wave.get_children():
			child.call_deferred("set", "visible", false)
			if child is CollisionShape3D:
				child.call_deferred("set", "disabled", true)

func _physics_process(delta):
	if Input.is_action_just_pressed("Wave Activate") and char_script.is_active_character and not is_activating:
		is_activating = true
		char_script.allow_movement = false
		# Differentiate between characters, as the have different times for the animations
		if char_script.name == "Elektro":
			char_script.play_animation("interaction")
			projectile_sound.play()
			await get_tree().create_timer(0.25).timeout
			trigger_wave()
			spawn_throw_effect()
		elif char_script.name == "Heavy":
			char_script.play_animation("jump")
			await get_tree().create_timer(2.0).timeout
			jump_sound.play()
			play_wave_animation()
			trigger_wave()
		elif char_script.name == "Screamo":
			char_script.play_animation("scream")
			await get_tree().create_timer(0.75).timeout
			scream_sound.play()
			trigger_wave()
			spawn_throw_effect()

	# Grow the wave collision shapes
	if wave_triggered:
		for wave in waves:
			for child in wave.get_children():
				if scale.z < max_scale:
					if is_single == false:
						scale.z += scale_speed * delta
						scale.x += scale_speed * delta
					else:
						scale.z += scale_speed * delta
				else:
					reset()
	
	update_throw_effects(delta)

func trigger_wave():
	wave_triggered = true
	for wave in waves:
		wave.call_deferred("set", "visible", true)
		for child in wave.get_children():
			child.call_deferred("set", "visible", true)
			if child is CollisionShape3D:
				# Activate the collision shapes to detect other areas
				child.call_deferred("set", "disabled", false)

# Reset position of certain or all wave segments on wall hit
func reset(WaveHit: Area3D = null):
	cleanup_throw_effects()
	# triggered if wave has been hit by a wall
	if WaveHit != null:
		WaveHit.call_deferred("set", "visible", false)
		for child in WaveHit.get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", true)
	# triggered to reset all the waves
	else:
		char_script.allow_movement = true
		wave_triggered = false
		is_activating = false
		scale = Vector3(1, 1, 1)
		for wave in waves:
			wave.call_deferred("set", "visible", false)
			for child in wave.get_children():
				child.scale = Vector3(1, 1, 1)
				if child is CollisionShape3D:
					child.set_deferred("disabled", true)
	
	
# check if walls are hit if any reset the wave segment
func _on_area_entered(hitting_area: Area3D, hit_area: Area3D):
	if hit_area.name.contains("ElektroWave"):
		# On collision with Elektro, spawn hit effect
		spawn_hit_effect(hit_area.global_position)

	if hitting_area.name.contains("GridMap"):
		reset(hit_area)

func play_wave_animation():
	# If char is Heavy, make the wave around him visible and grow
	var wave_model
	wave_model = char_script.get_node("WaveModel")
	var	wave_model_orig_scale = wave_model.scale
	wave_model.visible = true
	while wave_model.scale.x < 1.0:
		await get_tree().process_frame
		wave_model.scale += Vector3.ONE * 2.0 * get_physics_process_delta_time()
	wave_model.visible = false
	wave_model.scale = wave_model_orig_scale

func spawn_hit_effect(hit_position: Vector3):
	# Instantiate the hit effect of Elektro and set position based on area collision impact
	var hit_instance = electro_hit_scene.instantiate()
	get_tree().current_scene.add_child(hit_instance)
	hit_instance.global_position = hit_position
	hit_instance.scale = Vector3.ZERO
	
	animate_hit_effect(hit_instance)

func animate_hit_effect(hit_instance: Node3D):
	var tween = create_tween()
	tween.set_parallel(true)
	# Grow and rotate hit effect after spawning
	tween.tween_property(hit_instance, "scale", 
		Vector3.ONE * hit_effect_scale, hit_effect_duration)
	tween.tween_property(hit_instance, "rotation_degrees", 
		Vector3(0, 360, 0), hit_effect_duration)
	
	tween.tween_callback(func(): hit_instance.queue_free()).set_delay(hit_effect_duration)

func spawn_throw_effect():
	# If char is Elektro or Schall, instantiate their "throwable" waves
	var throw_instance = null
	if char_script.name == "Elektro":
		throw_instance = electro_throw_scene.instantiate()
	elif char_script.name == "Screamo":
		throw_instance = screamo_throw_scene.instantiate()
	else:
		return

	get_tree().current_scene.add_child(throw_instance)
	stop_throw = false

	# Base position and rotation on character
	throw_instance.global_position = char_script.global_position
	throw_instance.global_rotation = char_script.global_rotation
	
	var throw_direction = char_script.global_transform.basis.z
	
	var throw_data = {
		"instance": throw_instance,
		"direction": throw_direction,
		"start_position": throw_instance.global_position,
		"distance_traveled": 0.0
	}
	active_throw_effects.append(throw_data)

func update_throw_effects(delta: float):
	# Move throw effects
	if stop_throw:
		return
	for i in range(active_throw_effects.size() - 1, -1, -1):
		var throw_data = active_throw_effects[i]
		var throw_instance = throw_data.instance
		
		if not is_instance_valid(throw_instance):
			active_throw_effects.remove_at(i)
			continue
		
		var movement = throw_data.direction * throw_speed * delta
		throw_instance.global_position += movement
		throw_data.distance_traveled += movement.length()

func cleanup_throw_effects():
	# Remove throw effects on resetting wave
	stop_throw = true	
	for throw_data in active_throw_effects:
		if is_instance_valid(throw_data.instance):
			throw_data.instance.visible = false
			throw_data.instance.queue_free()
	
	active_throw_effects.clear()
