extends CanvasLayer

@onready var fader: ColorRect = $ColorRect

func fade_and_change_scene(scene_path: String) -> void:
	# make sure we start fully transparent
	fader.color = Color(0, 0, 0, 0)
	fader.visible = true

	# create a Tween and keep a reference to it
	var tween = get_tree().create_tween()
	# interpolate the ColorRect's alpha 0→1 over 1s
	tween.tween_property(fader, "color:a", 1.0, 2.0)
	# when that finishes, call _change_scene(scene_path)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/EndScene.tscn")
	#fader.visible = false
