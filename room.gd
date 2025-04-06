class_name Room
extends Node3D

@export var vert_offset: int = 0
@export var railHandler:RailHandler
@export var size: Vector3 = Vector3(20, 20, 20)

func get_doors() -> Array[Dictionary]:
	if not is_inside_tree():
		return []
	var doors:Array[Dictionary] = []
	print("start")
	for door:Marker3D in $Doors.get_children():
		for rail in railHandler.Rails:
			if rail.get_closest_point(door.global_transform.origin).distance_to(door.global_transform.origin) <=1:
				print(rail.get_closest_point(door.global_transform.origin))
				var mesh: MeshInstance3D = MeshInstance3D.new()
				var box:BoxMesh = BoxMesh.new()
				box.size = Vector3(5,5,5)
				mesh.mesh = box
				add_child(mesh)
				mesh.global_position = rail.get_closest_point(door.global_transform.origin)
		var dict :Dictionary ={
			"position": door.global_transform.origin,
			"direction": door.global_transform.basis.z.normalized(), # The forward direction
			"local_position": door.position,  # Position relative to the room
			"node": door,  # Reference to the door marker
			"rail_handler": railHandler
		}
		doors.append(dict)
	return doors
