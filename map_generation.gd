class_name MapGenerator
extends Node3D

@export var room_scenes: Array[PackedScene]  # Preset room scenes
@export var max_rooms: int = 10
@export var cart: Cart

var placed_rooms = []  # Stores placed rooms

class RoomInstance:
	var vert: int
	var node: Node3D
	var position: Vector3
	var size: Vector3  # Width, height, depth
	var doors: Array  # Door transforms

	func _init(n: Room, room_size: Vector3):
		node = n
		position = n.global_transform.origin
		vert = n.vert_offset
		size = room_size
		doors = []
		var door_container = n.find_child("Doors")
		if door_container:
			for child in door_container.get_children():
				doors.append(child.global_transform)
		else:
			print("Warning: No 'Doors' node found in room: ", n.name)


func generate_dungeon():
	for c in get_children():
		placed_rooms.clear()
		c.queue_free()
	if room_scenes.is_empty():
		print("No preset rooms assigned!")
		return

	# Place first room at (0, 0, 0)
	var root_room = place_first_room(room_scenes.pick_random())
	if not root_room:
		return
	
	var room_queue = [root_room]

	while room_queue.size() > 0 and placed_rooms.size() < max_rooms:
		var rand = randi_range(0,room_queue.size()-1)
		var current_room = room_queue.pop_at(rand)
		for existing_door in current_room.doors:
			if placed_rooms.size() < max_rooms:
				var new_room_scene = room_scenes.pick_random()
				var new_room_instance = try_place_room(existing_door, new_room_scene)
				if new_room_instance:
					room_queue.append(new_room_instance)
					print(str(placed_rooms.size()) + "/" + str(max_rooms))
					


func place_first_room(room_scene: PackedScene) -> RoomInstance:
	var room = room_scene.instantiate()
	add_child(room)
	# Get room size from a custom script or node (e.g., store dimensions in a "RoomData" node)
	var size = get_room_size(room)
	room.global_transform.origin = Vector3.ZERO  # Place at the center
	

	var room_data = RoomInstance.new(room, size)
	placed_rooms.append(room_data)
	print(str(placed_rooms.size()) + "/" + str(max_rooms))
	update_rails(room)
	return room_data

func update_rails(start:Room):
	var follower:TrackFollower = TrackFollower.new()
	follower.loop = false
	follower.cart = cart
	start.railHandler.Rails.pick_random().add_child(follower)
	cart.point = follower

func try_place_room(existing_door_transform: Transform3D, room_scene: PackedScene) -> RoomInstance:
	var rotations = [0, 90, 180, 270]
	for angle in rotations:
		var new_room = room_scene.instantiate()
		add_child(new_room)

		# Rotate before checking alignment
		new_room.rotate_y(deg_to_rad(angle))

		# Get room size
		var size = get_room_size(new_room)
		# Find a door that aligns
		for new_door in new_room.find_child("Doors").get_children():
			var _new_door_transform = new_door.global_transform

			# Rotate door position properly
			var rotated_door_position = new_room.to_global(new_door.transform.origin)
			var rotated_door_direction = new_room.to_global(new_door.transform.basis.z) - new_room.global_transform.origin

			# Ensure doors face each other
			var existing_facing = existing_door_transform.basis.z.normalized()
			var new_door_facing = -rotated_door_direction.normalized()
			if existing_facing.dot(new_door_facing) > 0.99:
				# Align door positions with buffer zone
				var offset = existing_door_transform.origin - rotated_door_position
				new_room.global_transform.origin += offset

				# Validate placement using room size
				var room_data = RoomInstance.new(new_room, size)
				if is_valid_position(room_data):
					
					placed_rooms.append(room_data)
					return room_data  # Successfully placed

		# Clean up failed placement
		new_room.queue_free()
	return null  # No valid placement found


func get_room_size(room: Room) -> Vector3:
	# Assume each room scene has a child node "RoomData" with width, height, depth properties
	if room:
		return Vector3(room.size.x, room.size.y, room.size.z)
	return Vector3(5, 5, 5)  # Default size if no data is found

func is_valid_position(room_data: RoomInstance) -> bool:
	# Add a buffer to avoid false overlap due to floating-point precision
	for placed_room in placed_rooms:
		if aabb_collision_check(placed_room, room_data):
			return false  # Prevent overlapping
	return true

# Check if two rooms are colliding using AABB with rotation support.
func aabb_collision_check(room1: RoomInstance, room2: RoomInstance) -> bool:
	var aabb:AABB = AABB(room1.position + Vector3(0,room1.vert,0),room1.size-Vector3(0.00001,0.00001,0.00001))
	var aabb2:AABB = AABB(room2.position + Vector3(0,room1.vert,0),room2.size-Vector3(0.00001,0.00001,0.00001))

	# Check if bounding boxes overlap in all axes
	return aabb.intersects(aabb2)

func print_debug_map():
	for room in placed_rooms:
		print("Room at ", room.position, " size: ", room.size, " rotation Y: ", rad_to_deg(room.node.rotation.y))
		for door in room.doors:
			print("  Door at ", door.origin)

func _ready():
	generate_dungeon()
