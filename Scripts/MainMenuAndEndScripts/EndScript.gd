extends Area3D

# List of character node names or paths to check
@export var character_names: Array[String] = ["Elektro", "Heavy", "Screamo"]
var present_characters := {}

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	self.collision_layer = 0

func _on_body_entered(body):
	if body.name in character_names:
		present_characters[body.name] = true
		_check_all_present()

func _on_body_exited(body):
	if body.name in character_names:
		present_characters.erase(body.name)

func _check_all_present():
	if character_names.all(func(char_name): return present_characters.has(char_name)):
		$FadeCanvas.fade_and_change_scene("res://Scenes/EndScene.tscn")
