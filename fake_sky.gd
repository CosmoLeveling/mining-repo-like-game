extends MeshInstance3D

@export var fake_sky:SubViewport
@export var camera_3d:Camera3D
@export var dummy_cam:Node3D

func _ready() -> void:
	add_to_group("fake_sky")
	fake_sky.size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))
	

func rotate_cam(main_cam):
	var main_cam_transform = main_cam.global_transform
	scale.y *= -1
	dummy_cam.global_transform = main_cam_transform
	scale.y *= -1
	camera_3d.global_transform = dummy_cam.global_transform
	camera_3d.global_transform.basis.x *= -1
	
