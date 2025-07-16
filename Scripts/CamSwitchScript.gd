extends Node3D

var minimap_container : CenterContainer
var hud_controller : CanvasLayer
var char_scripts = []
var current_cam : Camera3D
var cams = []
var current_cam_index = 0
var minimap_cam : Camera3D
var texture_rects
var current_active_rect : TextureRect = null
var active_cam_icon = "CamIcon1"

func _ready():
	minimap_container = get_node("MinimapCamera/MinimapLayer/CenterContainer")
	minimap_container.visible = false
	char_scripts.append(get_tree().get_root().get_node("Main/Elektro"))
	char_scripts.append(get_tree().get_root().get_node("Main/Heavy"))
	char_scripts.append(get_tree().get_root().get_node("Main/Screamo"))
	hud_controller = get_tree().get_root().get_node("Main/CanvasLayer")
	for child in get_children():
		if child is Camera3D:
			if child.name == "MinimapCamera":
				minimap_cam = child
			else:
				cams.append(child)
			
	if cams.size() > 0:
		cams[current_cam_index].current = true
		current_cam = cams[current_cam_index]
	setup_hover_effects()

func setup_hover_effects():
	texture_rects = minimap_container.find_children("*", "TextureRect", true)
	for rect in texture_rects:
		rect.mouse_entered.connect(_on_texture_rect_hovered.bind(rect))
		rect.mouse_exited.connect(_on_texture_rect_unhovered.bind(rect))

func _process(_delta: float) -> void:
	if minimap_container.visible:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered:
			active_cam_icon = hovered.name
	else:
		set_active_border(active_cam_icon)
		var index = 0
		for i in range(texture_rects.size()):
			if texture_rects[i].name == active_cam_icon:
				index = i
				break
		current_cam_index = index
		cams[current_cam_index].current = true
		current_cam = cams[current_cam_index]
		

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Switch Cam"):
		minimap_cam.current = true
		minimap_container.visible = true
		hud_controller.active_char = ""
		for character in char_scripts:
			character.is_active_character = false
	else:
		current_cam.current = true
		minimap_container.visible = false

func _on_texture_rect_hovered(rect: TextureRect):
	var tween = create_tween()
	tween.tween_property(rect, "scale", Vector2(0.4, 0.4), 0.1)

func _on_texture_rect_unhovered(rect: TextureRect):
	var tween = create_tween()
	tween.tween_property(rect, "scale", Vector2(0.3, 0.3), 0.1)

func set_active_border(camera_name: String):
	# Entferne alle vorherigen Borders
	remove_all_borders()
	
	# Warte einen Frame und füge neue Border hinzu
	await get_tree().process_frame
	
	# Finde das TextureRect mit dem entsprechenden Namen
	for rect in texture_rects:
		if rect.name == camera_name:
			add_red_border(rect)
			current_active_rect = rect
			break

func add_red_border(rect: TextureRect):
	# Erstelle einen NinePatchRect als Border
	var border = NinePatchRect.new()
	border.name = "RedBorder"
	border.texture = create_border_texture()
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignoriere Maus-Events
	
	# Setze Border größer als das TextureRect
	border.position = Vector2(-5, -5)
	border.size = rect.size + Vector2(10, 10)
	border.z_index = -1  # Hinter das TextureRect
	
	rect.add_child(border)

func remove_all_borders():
	for rect in texture_rects:
		var border = rect.get_node_or_null("RedBorder")
		if border:
			border.queue_free()

func create_border_texture() -> ImageTexture:
	# Erstelle eine einfache rote Border-Textur
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	
	# Mache das Innere transparent (nur Border)
	for x in range(4, 28):
		for y in range(4, 28):
			image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture
