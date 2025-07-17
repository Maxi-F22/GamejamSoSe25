extends Node3D  # Or the type of your main node

func _ready():
	var anim_player = $AnimationPlayer
	var idle_anim = anim_player.get_animation("idle")
	
	if idle_anim:
		idle_anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play("idle")
	else:
		push_warning("Idle animation not found!")
