extends Node3D

@export var speed: float = 5
@export var scale_speed: float = 1
@export var max_scale: float = 8
@export var char_script: CharacterBody3D

var wave_triggered = false
var waves = []
var forward

func _ready():
	for child in get_children():	
		waves.append(child)

	for wave in waves:
		if wave is Area3D:
			wave.body_entered.connect(_on_child_body_entered.bind(wave))
		for child in wave.get_children():
			child.call_deferred("set", "visible", true)
			if child is CollisionShape3D:
				child.call_deferred("set", "disabled", false)

func _physics_process(delta):
	if Input.is_action_just_pressed("WaveActivate"):# and char_script.is_active_character:
		trigger_wave()
	if(wave_triggered):
		for wave in waves:
			for child in wave.get_children():
				if scale.z < max_scale:
					#child.scale.z += scale_speed * delta
					scale.z += scale_speed * delta
					scale.x += scale_speed * delta
				else:
					reset()

#make waves Visible and trigger the expansion
func trigger_wave():
	wave_triggered = true
	#char_script.allow_movement = false
	for wave in waves:
		wave.call_deferred("set", "visible", true)
		for child in wave.get_children():
			child.call_deferred("set", "visible", true)
			if child is CollisionShape3D:
				child.call_deferred("set", "disabled", false)

#Reset position of certain or ALL wave segments
func reset(WaveHit: Area3D = null):
	#triggered if wave has been hit by a wall
	if WaveHit != null:
		WaveHit.call_deferred("set", "visible", false)
		for child in WaveHit.get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", true)
	#triggered to reset all the waves
	else:
		wave_triggered = false
		scale = Vector3(1, 1, 1)
		for wave in waves:
			wave.call_deferred("set", "visible", false)
			for child in wave.get_children():
				child.scale = Vector3(1, 1, 1)
				if child is CollisionShape3D:
					child.set_deferred("disabled", true)
	
			
#check if walls are hit if any reset the wave segment
func _on_child_body_entered(_body: Node, source: Area3D):
	reset(source)
	#TODO check falls bestimmte wände/obj getroffen werden
