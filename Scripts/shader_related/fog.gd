extends MeshInstance3D

func _process(delta):
	var cam = get_viewport().get_camera_3d()
	if cam and material_override:
		material_override.set_shader_parameter("camera_position", cam.global_transform.origin)
