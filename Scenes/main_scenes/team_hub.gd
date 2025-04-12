extends Node3D

@onready var drill: Drill = $Node3D
@onready var sub_viewport: SubViewport = $SubViewport
var loading_scene: PackedScene = load("res://Scenes/gui/Loading.tscn")
func _ready() -> void:
	drill._open_close()
	Engine.set_physics_ticks_per_second(roundi(DisplayServer.screen_get_refresh_rate()))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		drill._open_close()


func _on_node_3d_button_clicked() -> void:
	if GameManager.task != null:
		drill._open_close()
		await get_tree().create_timer(2).timeout
		GameManager.next_scene = "res://Scenes/main_scenes/map_generation_test.tscn"
		get_tree().change_scene_to_packed(loading_scene)
