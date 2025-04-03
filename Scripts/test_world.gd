extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_FORCE_QUIT"):
		get_tree().quit()


func _on_interaction_area_interact() -> void:
	print("worked")
