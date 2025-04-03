extends PathFollow3D

@export var cart:Cart

func _physics_process(delta: float) -> void:
	progress += cart.current_speed * delta
	var path: Rail = get_parent()
	if progress_ratio == 0 && path.prev_track:
		progress_ratio = 0.99
		reparent(path.prev_track,false)
		progress_ratio = 0.99
	elif progress_ratio == 1 && path.next_path:
		progress_ratio = 0.01
		reparent(path.next_path,false)
