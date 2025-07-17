extends Area3D

var glass_unit_object: Area3D
var is_deactivated = false
var anim_player: AnimationPlayer

func _ready() -> void:
	anim_player = get_node("WallModel/AnimationPlayer")
	collision_layer = 2
	area_entered.connect(_on_glass_area_entered)

func _physics_process(_delta):
	if is_deactivated:
		anim_player.play("Alle")
		await get_tree().create_timer(2.0).timeout
		queue_free()

func _on_glass_area_entered(area: Area3D):
	if area.name.contains("ScreamWave"):
		is_deactivated = true
