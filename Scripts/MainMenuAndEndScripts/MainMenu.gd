extends CanvasLayer

@export var LevelScene = preload("res://Scenes/main.tscn")


func _on_button_pressed() -> void:
	var scene = get_tree().current_scene
	if scene.name == "EndScene":
		get_tree().quit() # Exit game
	else:
		get_tree().change_scene_to_packed(LevelScene)
