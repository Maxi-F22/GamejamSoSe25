extends Area3D

# Implements functionality for reaching the end

# List of character node names or paths to check
@export var character_names: Array[String] = ["Elektro", "Heavy", "Screamo"]
var present_characters := {}

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	self.collision_layer = 0 # Set to 0, so that mouse raycast doesn't detect

# If character enters area, add to area and remove if leaves area
func _on_body_entered(body):
	if body.name in character_names:
		present_characters[body.name] = true
		_check_all_present()

func _on_body_exited(body):
	if body.name in character_names:
		present_characters.erase(body.name)

# If everybody is in area, load end scene
func _check_all_present():
	if character_names.all(func(char_name): return present_characters.has(char_name)):
		$FadeCanvas.fade_and_change_scene("res://Scenes/EndScene.tscn")
