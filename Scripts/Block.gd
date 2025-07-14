extends RigidBody3D

enum BlockType { RED, BLUE, GREEN }
var block_type: BlockType = BlockType.BLUE

# Bewegungsgeschwindigkeit
var move_force := 30.0

func _ready():
    connect("body_entered", _on_body_entered)
    _set_color()

func _physics_process(delta: float) -> void:
    var input_vector = Vector3.ZERO

    if Input.is_action_pressed("move_forward"):
        input_vector.z -= 1
    # if Input.is_action_pressed("move_backward"):
    #     input_vector.z += 1
    # if Input.is_action_pressed("move_left"):
    #     input_vector.x -= 1
    # if Input.is_action_pressed("move_right"):
    #     input_vector.x += 1

    input_vector = input_vector.normalized()
    if input_vector != Vector3.ZERO:
        apply_central_force(input_vector * move_force)

func _on_body_entered(body: Node) -> void:
    if body.name == "Wall":
        match block_type:
            BlockType.RED:
                print("🔴 Roter Block berührt die Mauer")
            BlockType.BLUE:
                print("🔵 Blauer Block berührt die Mauer")
            BlockType.GREEN:
                print("🟢 Grüner Block berührt die Mauer")

func _set_color():
    var mesh = $MeshInstance3D
    var mat := StandardMaterial3D.new()
    match block_type:
        BlockType.RED:
            mat.albedo_color = Color.RED
        BlockType.BLUE:
            mat.albedo_color = Color.BLUE
        BlockType.GREEN:
            mat.albedo_color = Color.GREEN
    mesh.material_override = mat
