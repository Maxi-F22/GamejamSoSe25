extends Node3D
@export var speed: float = 15


@export var scale_speed: float = 15
@export var max_scale_x: float = 15
var wave_triggered = false

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("WaveActivate"):
		trigger_wave(delta)
	if(wave_triggered):
		if scale.x < max_scale_x:
			scale.x += scale_speed * delta
			scale.z += scale_speed * delta
		else:
			wave_triggered = false
			reset()
func trigger_wave(delta):
	wave_triggered = true
func reset():
	scale = Vector3(1, 1, 1)
