extends Node3D

@onready var minimap_root := $CanvasLayer/Control # Control-Node, wo Icons rein sollen

var icon_texture: Texture2D = load("res://Assets/HUD/cam_icon.png")
var border_texture: Texture2D = load("res://Assets/HUD/cam_border.png")
var overlay_container : CenterContainer
var hud_controller : CanvasLayer
var char_scripts = []
var current_cam : Camera3D
var cams = []
var current_cam_index = 0
var minimap_cam : Camera3D
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
		
		# Anchor-Mode für bessere Positionierung
		icon.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)

		minimap_root.add_child(icon)
		texture_rects.append(icon)  # Zur Liste hinzufügen
		cam.set_meta("icon", icon) # Speichere das Icon im Kamera-Node
		if i == 0:
			active_cam_icon = icon.name

func setup_hover_effects():
	for rect in texture_rects:
		rect.mouse_entered.connect(_on_texture_rect_hovered.bind(rect))
		rect.mouse_exited.connect(_on_texture_rect_unhovered.bind(rect))

func _process(_delta: float) -> void:
	for i in range(cams.size()):
		var cam = cams[i]
		var world_pos = cam.global_position
		
		# Projiziere Welt-Position auf Minimap-Kamera
		var screen_pos = minimap_cam.unproject_position(world_pos)
		
		# Prüfe ob Position im Viewport ist
		var viewport_size = get_viewport().size
		if screen_pos.x < 0 or screen_pos.x > viewport_size.x or screen_pos.y < 0 or screen_pos.y > viewport_size.y:
			continue  # Position außerhalb des Viewports
		
		# Konvertiere zu Control-Koordinaten
		var control_rect = minimap_root.get_rect()
		var relative_pos = Vector2(
			(screen_pos.x / viewport_size.x) * control_rect.size.x,
			(screen_pos.y / viewport_size.y) * control_rect.size.y
		)
		
		var icon = cam.get_meta("icon")
		if icon:
			# Zentriere Icon auf Position
			icon.position = relative_pos - icon.size / 2

	if minimap_root.visible:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered and hovered.name.contains("CameraIcon"):
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
		minimap_root.visible = true
		overlay_container.visible = false
		hud_controller.active_char = ""
		for character in char_scripts:
			character.is_active_character = false
	else:
		current_cam.current = true
		minimap_root.visible = false
		overlay_container.visible = true

func _on_texture_rect_hovered(rect: TextureRect):
	var tween = create_tween()
	tween.tween_property(rect, "scale", Vector2(1.2, 1.2), 0.1)

func _on_texture_rect_unhovered(rect: TextureRect):
	var tween = create_tween()
	tween.tween_property(rect, "scale", Vector2(1, 1), 0.1)

func set_active_border(camera_name: String):
    # Entferne alle vorherigen Borders
	remove_all_borders()
    
    # Warte einen Frame und füge neue Border hinzu
	await get_tree().process_frame
    
    # Finde das TextureRect mit dem entsprechenden Namen
	for rect in texture_rects:
		if rect.name == camera_name:
			add_png_border(rect)
			current_active_rect = rect
			break

func add_png_border(rect: TextureRect):
    # Erstelle TextureRect für PNG-Border
	var border = TextureRect.new()
	border.name = "PngBorder" + rect.name
	border.texture = border_texture  # Verwende das geladene PNG
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignoriere Maus-Events
    
    # Erweiterte Konfiguration für das Border-PNG
	border.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	border.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    
    # Border größer als das Icon machen
	var border_scale = 1.2 
	border.size = rect.size * border_scale
	border.position = Vector2(
		-(border.size.x - rect.size.x) / 2,  # Zentriere horizontal
		-(border.size.y - rect.size.y) / 2   # Zentriere vertikal
	)
    
	border.z_index = -1  # Hinter das Icon
    
    # Border als erstes Kind hinzufügen (damit es hinten erscheint)
	rect.add_child(border)
	rect.move_child(border, 0)

func remove_all_borders():
	for rect in texture_rects:
		var border = rect.get_node_or_null("PngBorder" + rect.name)  # Neuer Name
		if border:
			border.queue_free()