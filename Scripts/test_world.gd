extends Node3D
@export var generator : MapGenerator
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_FORCE_QUIT"):
		get_tree().quit()
	if event.is_action_pressed("ui_up"):
		generator.generate_dungeon()
