extends CanvasLayer

@export var LevelScene = preload("res://Scenes/main.tscn")


func _on_button_pressed() -> void:
	var scene = get_tree().current_scene
	print(scene)
	if scene.name == "EndScene":  # or use scene.scene_file_path
		get_tree().quit()  # Exit the game
	else:
		get_tree().change_scene_to_packed(LevelScene)
