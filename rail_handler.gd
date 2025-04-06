class_name RailHandler
extends Node3D

@export var Rails: Array[Rail]
var Current_Rail: Rail

func _ready() -> void:
	Current_Rail = Rails.get(0)

func get_closest_rail(pos:Vector3) -> Rail:
	var closest_points:Dictionary[Rail,Vector3]
	for rail in Rails:
		closest_points[rail] = rail.get_closest_point(pos)
	var distances:Dictionary[Rail,float]
	for point in closest_points.keys():
		var dist:float = pos.distance_to(closest_points[point])
		distances[point] = dist
	var closest_rails:Array[Rail]
	var smallest_distance:float
	for distance in distances.keys():
		if smallest_distance>distances[distance]||!smallest_distance:
			closest_rails.clear()
			smallest_distance = distances[distance]
			closest_rails.append(distance)
		elif smallest_distance == distances[distance]:
			closest_rails.append(distance)
	
	return closest_rails.pick_random()
