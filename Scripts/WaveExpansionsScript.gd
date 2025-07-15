extends Node3D

@export var speed: float = 15
@export var scale_speed: float = 15
@export var max_scale: float = 10
@export var char_script: CharacterBody3D

var wave_triggered = false
var waves = []
var forward

func _ready():
	for child in get_children():	
		child.body_entered.connect(_on_body_entered)
		waves.append(child)

	for wave in waves:
		for child in wave.get_children():
			child.visible = false
			if child is CollisionShape3D:
				child.disabled = true

func _physics_process(delta):
	if Input.is_action_just_pressed("Wave Activate") and char_script.is_active_character:
		trigger_wave()
	if(wave_triggered):
		for wave in waves:
			for child in wave.get_children():
				if child.scale.z < max_scale:
					child.scale.z += scale_speed * delta
				else:
					reset()

func trigger_wave():
	wave_triggered = true
	char_script.allow_movement = false
	for wave in waves:
		for child in wave.get_children():
			child.visible = true
			if child is CollisionShape3D:
				child.disabled = false

func reset():
	wave_triggered = false
	char_script.allow_movement = true
	for wave in waves:
		for child in wave.get_children():
			child.scale = Vector3(1, 1, 1)
			child.visible = false
			if child is CollisionShape3D:
				child.disabled = true

#check if walls are hit if any reset the wave segment
func _on_body_entered(body: StaticBody3D):
	print(body)
	if body.is_in_group("Wall"):
		print("hitarea")
		reset()
