extends Area3D

# Implements functionality for breaking the walls  

var glass_unit_object: Area3D
var is_deactivated = false
var anim_player: AnimationPlayer
var wall_destroy_sound: AudioStreamPlayer3D

func _ready() -> void:
	wall_destroy_sound = get_node("WallDestroySound")
	anim_player = get_node("WallModel/AnimationPlayer")
	collision_layer = 2 # collision layer for detecting the player waves
	area_entered.connect(_on_glass_area_entered)

func _physics_process(_delta):
	if is_deactivated:
		# Play the merged animation for all different meshes in the wall object and delete object
		anim_player.play("Alle")
		await get_tree().create_timer(2.0).timeout
		queue_free()

func _on_glass_area_entered(area: Area3D):
	# If character is Schall, break wall
	if area.name.contains("ScreamWave"):
		is_deactivated = true
		wall_destroy_sound.play()
