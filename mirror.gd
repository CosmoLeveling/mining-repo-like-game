extends MeshInstance3D
@onready var dummy_cam: Node3D = $DummyCam
@onready var camera_3d: Camera3D = $SubViewport/Camera3D

func _ready() -> void:
	add_to_group("mirrors")
	$SubViewport.size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))
	
func update_cam(main_cam):
	var main_cam_transform = main_cam.global_transform
	scale.y *= -1
	dummy_cam.global_transform = main_cam_transform
	scale.y *= -1
	camera_3d.global_transform = dummy_cam.global_transform
	camera_3d.global_transform.basis.x *= -1
