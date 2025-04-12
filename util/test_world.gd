extends Node3D
@export var generator : MapGenerator
@onready var drill_ship: Drill = $DrillShip

func _ready() -> void:
	Engine.set_physics_ticks_per_second(roundi(DisplayServer.screen_get_refresh_rate()))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_FORCE_QUIT"):
		get_tree().quit()
	if event.is_action_pressed("ui_up"):
		generator.generate_dungeon()


func _on_loading_done_loading() -> void:
	drill_ship._open_close()
