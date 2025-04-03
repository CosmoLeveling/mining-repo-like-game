extends Node3D

@export var start_room: PackedScene

@export var room_scenes: Array[PackedScene] # Array of room scenes
@export var max_rooms: int = 10 # Limit to prevent infinite generation

var placed_rooms = []

func _ready() -> void:
	generate_map()

func generate_map():
	var start = start_room.instantiate()
	add_child(start)
	start.global_transform.origin = Vector3.ZERO
	placed_rooms.append(start)
	
	var open_doors: Array[Dictionary] = start.get_doors() # Function to get door positions
	var room_count = 1
	
	while room_count < max_rooms and open_doors.size() > 0:
		var door_position = open_doors.pop_front()
		var new_room = place_room_at(door_position)
		if new_room:
			placed_rooms.append(new_room)
			room_count += 1
			open_doors.append_array(new_room.get_doors())

func place_room_at(existing_door_data) -> Node3D:
	var new_room = room_scenes[randi() % room_scenes.size()].instantiate()
	add_child(new_room)  # Ensure the room is in the scene tree before calling get_doors()
	# Ensure new_room is of type Room
	if not new_room.has_method("get_doors") or not new_room is Room:
		push_error("Room does not have the expected script attached!")
		remove_child(new_room)
		new_room.queue_free()
		return null
	var rotations = [0, 90, 180, 270]
	for _r in rotations.size():
		var rand = randi_range(0, rotations.size() - 1)
		var rot = rotations.pop_at(rand)
		new_room.rotation.y = deg_to_rad(rot)
		var new_doors = new_room.get_doors()  # Get doors after adding
		for new_door in new_doors:
			if typeof(existing_door_data) == TYPE_DICTIONARY and typeof(new_door) == TYPE_DICTIONARY:
				if existing_door_data.has("direction") and new_door.has("direction"):
					if existing_door_data["direction"].dot(new_door["direction"]) < -0.9:
						# Ensure parent room has size
						var parent_room = existing_door_data["node"]
						# Keep moving up the hierarchy until we find a Room node
						while parent_room and not (parent_room is Room):
							parent_room = parent_room.get_parent()
						
						if not parent_room:
							push_error("Parent room missing Room script! Could not find Room node.")
							return null
						# Align new room directly to the door position of the parent room
						var parent_door_pos = existing_door_data["position"]
						var new_door_local_pos = new_door["local_position"]
						# Calculate new position of the room to align doors
						var alignment_offset = parent_door_pos - new_room.to_global(new_door_local_pos)
						new_room.global_transform.origin += alignment_offset
						# Ensure no overlap
						if not check_overlap(new_room):
							return new_room  # Successfully placed
	# Remove the room if no valid placement is found
	remove_child(new_room)
	new_room.queue_free()
	return null


func check_overlap(new_room: Node3D) -> bool:
	# Get new room's global position and size (assuming it's a Vector2)
	var _new_pos = new_room.global_transform.origin
	var _new_size = new_room.size
	
	for room in placed_rooms:
		var _room_pos = room.global_transform.origin
		var _room_size = room.size
		
		# Get the AABB for both rooms (2D)
		var new_aabb = get_aabb_2d(new_room)
		var room_aabb = get_aabb_2d(room)
		
		# Check if the AABBs overlap
		if new_aabb.intersects(room_aabb):
			return true
	
	return false  # No overlap
	
func get_aabb_2d(room: Node3D) -> AABB:
	var size = room.size  # Vector3, assuming X and Z dimensions
	var room_transform = room.global_transform  # Rename transform to room_transform
	var half_extents = Vector2(size.x * 0.5, size.y * 0.5)  # Use X and Z for 2D size (Y is vertical)

	# Transform the corners of the bounding box to world space (2D)
	var corners = [
		room_transform.origin + room_transform.basis.x * half_extents.x + room_transform.basis.z * half_extents.y,
		room_transform.origin + room_transform.basis.x * half_extents.x - room_transform.basis.z * half_extents.y,
		room_transform.origin - room_transform.basis.x * half_extents.x + room_transform.basis.z * half_extents.y,
		room_transform.origin - room_transform.basis.x * half_extents.x - room_transform.basis.z * half_extents.y
	]
	
	# Initialize the AABB with extreme values
	var min_corner = Vector3(99999, 0, 99999)  # Set y = 0 since we are working in 2D
	var max_corner = Vector3(-99999, 0, -99999)  # Set y = 0 since we are working in 2D
	
	# Get the min and max points of the AABB in 2D
	for corner in corners:
		min_corner.x = min(min_corner.x, corner.x)
		min_corner.z = min(min_corner.z, corner.z)  # Use z as the Y axis (2D space)
		max_corner.x = max(max_corner.x, corner.x)
		max_corner.z = max(max_corner.z, corner.z)  # Use z as the Y axis (2D space)
	
	# Return the AABB (bounding box)
	return AABB(min_corner, max_corner - min_corner)  # AABB constructor uses Vector3
