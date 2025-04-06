class_name TrackFollower
extends PathFollow3D

@export var cart: Cart

func _physics_process(delta: float) -> void:
	progress += cart.current_speed * delta * -1 if cart.flipped else cart.current_speed * delta
	var current_rail:Rail = get_parent()
	if (progress_ratio == 1 && current_rail.nextRailHandler):
		var rail:Rail = current_rail.nextRailHandler.get_closest_rail(global_transform.origin)
		if rail:
			print("test")
			progress_ratio = 0.000001
			reparent(rail,false)
			progress_ratio = 0.000001
	elif (progress_ratio == 0 && current_rail.prevRailHandler):
		var rail:Rail = current_rail.prevRailHandler.get_closest_rail(global_transform.origin)
		if rail:
			print("test")
			progress_ratio = 0.999999
			reparent(rail,false)
			progress_ratio = 0.999999
