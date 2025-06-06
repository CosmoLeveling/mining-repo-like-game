class_name Room
extends Node3D

@export var offset:Vector3
@export var size: Vector3 = Vector3(20, 20, 20)

func get_doors() -> Array[Dictionary]:
	if not is_inside_tree():
		return []
	var doors:Array[Dictionary] = []
	for door:Marker3D in $Doors.get_children():
		var dict :Dictionary ={
			"position": door.global_transform.origin,
			"direction": door.global_transform.basis.z.normalized(), # The forward direction
			"local_position": door.position,  # Position relative to the room
			"node": door  # Reference to the door marker
		}
		doors.append(dict)
	return doors
	
func get_ores() -> Array[Marker3D]:
	if not is_inside_tree():
		return []
	var ores:Array[Marker3D] = []
	if has_node("OreSpawners"):
		for c:Marker3D in $OreSpawners.get_children():
			ores.append(c)
	return ores
