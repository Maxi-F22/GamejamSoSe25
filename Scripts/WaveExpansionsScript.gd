extends Area3D

@export var speed: float = 5.0
@export var scale_speed: float = 40
@export var max_scale: float = 15
var wave_triggered = false
var forward
func _ready():
	set_process(true)
	area_entered.connect(_on_area_entered)
	for child in get_children():
		child.visible = false
		if child is CollisionShape3D:
			child.disabled = true
	#forward = -transform.basis.z 

#continously scale wave until max scale is hit
func _process(delta):
	if Input.is_action_just_pressed("WaveActivate"):
		trigger_wave(delta)
	if(wave_triggered):
		for child in get_children():
			if child.scale.z < max_scale:
				child.scale.z += scale_speed * delta
				#child.translate(forward * speed * delta)
			else:
				reset()

#Make waves visible and triger the scaling
func trigger_wave(delta):
	wave_triggered = true
	for child in get_children():
		child.visible = true
		if child is CollisionShape3D:
			child.disabled = false

#Reset position of waves and make em invisible
func reset():
	wave_triggered = false
	
	for child in get_children():
		child.visible = false
		child.scale = Vector3(1, 1, 1)
		child.position = Vector3(0,0,0)
		if child is CollisionShape3D:
			child.disabled = true

#check if walls are hit if any reset the wave segment
func _on_area_entered(area: Area3D):
	print("hitbefore")
	if area.is_in_group("Wall"):
		print("hitarea")
		reset()
