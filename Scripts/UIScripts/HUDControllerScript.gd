extends CanvasLayer

@onready var _hud_container := $CenterContainer as CenterContainer

var border_heavy_texture: Texture2D = load("res://Assets/HUD/fat_border.png")
var border_screamo_texture: Texture2D = load("res://Assets/HUD/woman_border.png")
var border_elektro_texture: Texture2D = load("res://Assets/HUD/elektro_border.png")
var active_char = ""
var char_elektro : CharacterBody3D
var char_heavy : CharacterBody3D
var char_screamo : CharacterBody3D
var current_active_rect : TextureRect = null
var texture_rects = []

func _ready() -> void:
	_hud_container.visible = false
	char_elektro = get_tree().get_root().get_node("Main/Elektro")
	char_heavy = get_tree().get_root().get_node("Main/Heavy")
	char_screamo = get_tree().get_root().get_node("Main/Screamo")
	texture_rects = _hud_container.find_children("*", "TextureRect", true)
	setup_hover_effects()

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

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Character Menu"):
		_hud_container.visible = true

	else:
		_hud_container.visible = false

func _process(_delta):
	if _hud_container.visible:
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered and (hovered.name.contains("Elektro") or hovered.name.contains("Heavy") or hovered.name.contains("Screamo")):
			active_char = hovered.name

	else:
		set_active_border(active_char)
		if active_char == "Elektro":
			char_elektro.is_active_character = true
			char_heavy.is_active_character = false
			char_screamo.is_active_character = false
		elif active_char == "Heavy":
			char_elektro.is_active_character = false
			char_heavy.is_active_character = true
			char_screamo.is_active_character = false
		elif active_char == "Screamo":
			char_elektro.is_active_character = false
			char_heavy.is_active_character = false
			char_screamo.is_active_character = true

func set_active_border(char_name: String):
	# Entferne alle vorherigen Borders
	remove_all_borders()
	
	# Warte einen Frame und füge neue Border hinzu
	await get_tree().process_frame
	
	# Finde das TextureRect mit dem entsprechenden Namen
	for rect in texture_rects:
		if rect.name == char_name:
			add_png_border(rect, char_name)
			current_active_rect = rect
			break

func add_png_border(rect: TextureRect, char_name: String):
	# Erstelle TextureRect für PNG-Border
	var border = TextureRect.new()
	border.name = "PngBorder"
	if char_name == "Elektro":
		border.texture = border_elektro_texture
	elif char_name == "Screamo":
		border.texture = border_screamo_texture
	elif char_name == "Heavy":
		border.texture = border_heavy_texture
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Erweiterte Konfiguration für das Border-PNG
	border.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	border.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Border größer als das Icon machen
	var border_scale = 1.1
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
		var border = rect.get_node_or_null("PngBorder")  # Neuer Name
		if border:
			border.queue_free()
