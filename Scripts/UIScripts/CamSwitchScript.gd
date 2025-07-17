extends Node3D

# Implements Camera Switching functionality

@onready var minimap_root := $CanvasLayer/Control

var icon_texture: Texture2D = load("res://Assets/HUD/cam_icon.png")
var border_texture: Texture2D = load("res://Assets/HUD/cam_border.png")
var overlay_container : CenterContainer
var hud_controller : CanvasLayer
var char_scripts = []
var current_cam : Camera3D
var cams = []
var current_cam_index = 0
var minimap_cam : Camera3D # The camera that shows the whole level, used as overlay "map"
var texture_rects = []
var current_active_rect : TextureRect = null
var active_cam_icon = ""

func _ready():
	overlay_container = get_node("CanvasLayer/OverlayContainer")
	minimap_root.visible = false
	overlay_container.visible = true
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
	create_camera_icons()
	setup_hover_effects()
	
func create_camera_icons():
	# creates the camera icons based on the amount of cameras
	for i in range(cams.size()):
		var cam = cams[i]
		var icon = TextureRect.new()
		icon.name = "CameraIcon" + str(i+1)
		icon.texture = icon_texture
		
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		icon.custom_minimum_size = Vector2(48, 48)
		icon.size = Vector2(48, 48)
		
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		
		icon.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)

		minimap_root.add_child(icon)
		texture_rects.append(icon) 
		cam.set_meta("icon", icon) 
		if i == 0:
			active_cam_icon = icon.name

func _process(_delta: float) -> void:
	for i in range(cams.size()):
		# For every camera, place the icon in the overlay, according to the position relative to the minimap_cam
		var cam = cams[i]
		var world_pos = cam.global_position
		var screen_pos = minimap_cam.unproject_position(world_pos)
		
		var viewport_size = get_viewport().size
		if screen_pos.x < 0 or screen_pos.x > viewport_size.x or screen_pos.y < 0 or screen_pos.y > viewport_size.y:
			continue
		var control_rect = minimap_root.get_rect()
		var relative_pos = Vector2(
			(screen_pos.x / viewport_size.x) * control_rect.size.x,
			(screen_pos.y / viewport_size.y) * control_rect.size.y
		)

		var icon = cam.get_meta("icon")
		if icon:
			icon.position = relative_pos - icon.size / 2

	if minimap_root.visible:
		# Select icons based on mouse hover and set active cam-icon
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered and hovered.name.contains("CameraIcon"):
			active_cam_icon = hovered.name
	else:
		# If any cam-icon is active, set as current camera and switch to it
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
	# Show overlay if button pressed and deactivate character control
	if Input.is_action_pressed("Switch Cam"):
		minimap_cam.current = true
		minimap_root.visible = true
		overlay_container.visible = false
		hud_controller.active_char = ""
		for character in char_scripts:
			character.is_active_character = false
	else:
		current_cam.current = true
		minimap_root.visible = false
		overlay_container.visible = true

# Grow on mouse hover
func setup_hover_effects():
	for rect in texture_rects:
		rect.mouse_entered.connect(_on_texture_rect_hovered.bind(rect))
		rect.mouse_exited.connect(_on_texture_rect_unhovered.bind(rect))

func _on_texture_rect_hovered(rect: TextureRect):
	var tween = create_tween()
	tween.tween_property(rect, "scale", Vector2(1.2, 1.2), 0.1)

func _on_texture_rect_unhovered(rect: TextureRect):
	var tween = create_tween()
	tween.tween_property(rect, "scale", Vector2(1, 1), 0.1)

func set_active_border(camera_name: String):
	remove_all_borders()
	await get_tree().process_frame
	for rect in texture_rects:
		if rect.name == camera_name:
			add_png_border(rect)
			current_active_rect = rect
			break

func add_png_border(rect: TextureRect):
	# Add the png of the border behind the cameras
	var border = TextureRect.new()
	border.name = "PngBorder" + rect.name
	border.texture = border_texture
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE # ignore mouse so that it only detects camera icons
	
	border.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	border.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var border_scale = 1.2 
	border.size = rect.size * border_scale
	border.position = Vector2(
		-(border.size.x - rect.size.x) / 2,
		-(border.size.y - rect.size.y) / 2
	)
	
	border.z_index = -1

	rect.add_child(border)
	rect.move_child(border, 0)

func remove_all_borders():
	for rect in texture_rects:
		var border = rect.get_node_or_null("PngBorder" + rect.name)
		if border:
			border.queue_free()
