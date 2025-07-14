extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Blocktypen
enum BlockType { SCHALLWELLE, DRUCK, STROM }
var block_type: BlockType = BlockType.SCHALLWELLE  # << Typ hier manuell ändern

func _ready():
	_set_color()

	# Area3D-Signal verbinden
	var area = $Area3D
	if area:
		area.connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	# Schwerkraft
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Springen
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Bewegung (Pfeiltasten)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# Setzt die Blockfarbe entsprechend dem Typ
func _set_color():
	var mesh = $MeshInstance3D
	if mesh:
		var mat := StandardMaterial3D.new()
		match block_type:
			BlockType.SCHALLWELLE:
				mat.albedo_color = Color.RED
			BlockType.DRUCK:
				mat.albedo_color = Color.BLUE
			BlockType.STROM:
				mat.albedo_color = Color.GREEN
		mesh.material_override = mat

# Reaktion bei Berührung mit der Mauer
func _on_body_entered(body: Node) -> void:
	if body.name == "Wall":
		match block_type:
			BlockType.SCHALLWELLE:
				print("🔴 SCHALLWELLE berührt die Mauer")
			BlockType.DRUCK:
				print("🔵 DRUCK berührt die Mauer")
			BlockType.STROM:
				print("🟢 STROM berührt die Mauer")
