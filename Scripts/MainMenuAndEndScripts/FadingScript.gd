extends CanvasLayer

# Implements overlay screen for end scene

@onready var fader: ColorRect = $ColorRect

func fade_and_change_scene(_scene_path: String) -> void:
	# Start overlay screen fully transparent
	fader.color = Color(0, 0, 0, 0)
	fader.visible = true

	var tween = get_tree().create_tween()
	# Tween to interpolate the ColorRect's alpha 0→1 over 1s
	tween.tween_property(fader, "color:a", 1.0, 2.0)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/EndScene.tscn")