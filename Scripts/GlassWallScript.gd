extends Area3D

var glass_unit_object: Area3D
var is_deactivated = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 2
	area_entered.connect(_on_glass_area_entered)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if is_deactivated:
		await get_tree().create_timer(1.5).timeout
		queue_free()
		

func _on_glass_area_entered(area: Area3D):
	if area.name.contains("ScreamWave"):
		is_deactivated = true
