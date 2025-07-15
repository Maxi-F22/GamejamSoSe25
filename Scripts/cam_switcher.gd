extends Node3D

var cams = []
var current_cam_index = 1
@export var current_cam : Camera3D

func _ready():
    for child in get_children():
        if child is Camera3D:
            cams.append(child)
            
    if cams.size() > 0:
        cams[current_cam_index].current = true
        current_cam = cams[current_cam_index]
        

func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("Switch Cam"):
        cams[current_cam_index].current = false
        
        current_cam_index += 1
        if current_cam_index >= cams.size():
            current_cam_index = 0
        
        cams[current_cam_index].current = true
        current_cam = cams[current_cam_index]