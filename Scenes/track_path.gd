class_name Rail
extends Path3D

@export var nextRailHandler: RailHandler
@export var prevRailHandler: RailHandler

func get_closest_point(pos:Vector3) -> Vector3:
	var distance_1 : float = pos.distance_to(curve.get_point_position(0)+global_transform.origin)
	var distance_2 : float = pos.distance_to(curve.get_point_position(curve.point_count-1)+global_transform.origin)
	if (distance_1 < distance_2):
		return curve.get_point_position(0)+global_transform.origin
	else:
		return curve.get_point_position(curve.point_count-1)+global_transform.origin
func reverse_curve():
	var new_curve = Curve3D.new()
	
	for i in range(curve.point_count - 1, -1, -1):  # Reverse order
		var point = curve.get_point_position(i)
		var in_tangent = curve.get_point_out(i)  # Swap in <-> out
		var out_tangent = curve.get_point_in(i)
		
		new_curve.add_point(point, in_tangent, out_tangent)
	
	curve = new_curve  # Replace the existing curve
