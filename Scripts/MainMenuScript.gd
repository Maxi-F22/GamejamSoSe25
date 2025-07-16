extends CanvasLayer

@export var LevelScene = preload("res://Scenes/Main.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(LevelScene)
