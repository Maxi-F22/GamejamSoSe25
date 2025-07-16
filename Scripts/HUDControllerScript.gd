extends CanvasLayer

@onready var _hud_container := $CenterContainer as CenterContainer

var active_char = ""
var char_elektro : CharacterBody3D
var char_heavy : CharacterBody3D
var char_screamo : CharacterBody3D
var current_active_rect : TextureRect = null

func _ready() -> void:
	_hud_container.visible = false
	char_elektro = get_tree().get_root().get_node("Main/Elektro")
	char_heavy = get_tree().get_root().get_node("Main/Heavy")
	char_screamo = get_tree().get_root().get_node("Main/Screamo")
	setup_hover_effects()

func setup_hover_effects():
	var texture_rects = _hud_container.find_children("*", "TextureRect", true)
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
		if hovered:
			active_char = hovered.name

	else:
		set_active_character_border(active_char)
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

func set_active_character_border(character_name: String):
	# Entferne alle vorherigen Borders
	remove_all_borders()
    
	# Warte einen Frame und füge neue Border hinzu
	await get_tree().process_frame
    
	# Finde das TextureRect mit dem entsprechenden Namen
	var texture_rects = _hud_container.find_children("*", "TextureRect", true)
	for rect in texture_rects:
		if rect.name == character_name:
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
	var texture_rects = _hud_container.find_children("*", "TextureRect", true)
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