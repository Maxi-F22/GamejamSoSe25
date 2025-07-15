extends CanvasLayer

@onready var _hud_container := $CenterContainer as CenterContainer

var active_char = ""
var char_elektro : CharacterBody3D
var char_heavy : CharacterBody3D
var char_screamo : CharacterBody3D

func _ready() -> void:
	_hud_container.visible = false
	char_elektro = get_tree().get_root().get_node("Main/Elektro")
	char_heavy = get_tree().get_root().get_node("Main/Heavy")
	char_screamo = get_tree().get_root().get_node("Main/Screamo")

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
