extends RigidBody3D

@export var push_speed: float = 5.0
var is_being_pushed = false
var push_direction = Vector3.ZERO
var original_freeze_mode

func _ready() -> void:
	var box_area = get_node("BoxArea")
	box_area.collision_layer = 2
	box_area.area_entered.connect(_on_box_area_entered)

	# Speichere original freeze mode
	original_freeze_mode = freeze_mode

func _physics_process(delta: float) -> void:
	if is_being_pushed:
		# Bewege Box linear in Richtung
		var new_position = global_position + push_direction * push_speed * delta
		global_position = new_position

func _on_box_area_entered(area: Area3D):
	if area.name.contains("MassWave"):
		# Get parent object of wave's parent (Player Object) and push box away
		var player = area.get_parent().get_parent()
		push_away_from_player(player)

func push_away_from_player(player: Node3D):
	is_being_pushed = true
    
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

	# Berechne Richtung von Spieler zur Box
	var raw_direction = (global_position - player.global_position).normalized()
	raw_direction.y = 0  # Keine Y-Bewegung
    
	# Reduziere auf Hauptachsen (nur X oder Z)
	push_direction = get_cardinal_direction(raw_direction)
			
	# Stoppe alle Bewegung
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

# Konvertiert eine Richtung zur nächsten Hauptachse
func get_cardinal_direction(direction: Vector3) -> Vector3:
	# Bestimme welche Achse stärker ist
	if abs(direction.x) > abs(direction.z):
		# X-Achse dominiert
		if direction.x > 0:
			return Vector3(1, 0, 0)   # Rechts
		else:
			return Vector3(-1, 0, 0)  # Links
	else:
		# Z-Achse dominiert
		if direction.z > 0:
			return Vector3(0, 0, 1)   # Vorwärts
		else:
			return Vector3(0, 0, -1)  # Rückwärts