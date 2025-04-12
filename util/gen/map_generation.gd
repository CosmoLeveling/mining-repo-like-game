class_name MapGenerator
extends Node3D
signal gen_next
var thread: Thread
@export var debug: bool
@export var start_scene: PackedScene
@export var door_fill_scene: PackedScene
@export var room_scenes: Array[PackedScene]  # Preset room scenes
@export var max_rooms: int = 10
@export var cart: Cart
@export var Player:player
@export var view_dist:float
@onready var loading: CanvasLayer = $"../Loading"
@onready var drill_ship: Drill = $"../DrillShip"

var placed_rooms = []  # Stores placed rooms

func _process(_delta: float) -> void:
	for room:RoomInstance in placed_rooms:
		var node = room.node
		var dist = node.global_position.distance_to(Player.chara.global_position)
		node.visible = dist < view_dist

class RoomInstance:
	var offset: Vector3
	var node: Node3D
	var position: Vector3
	var size: Vector3  # Width, height, depth
	var doors: Array  # Door transforms

	func _init(n: Room, room_size: Vector3):
		node = n
		position = n.global_transform.origin
		offset = n.offset
		size = room_size
		doors = []
		var door_container = n.find_child("Doors")
		if door_container:
			for child in door_container.get_children():
				doors.append(child.global_transform)
		else:
			print("Warning: No 'Doors' node found in room: ", n.name)


func generate_dungeon():
	if call_deferred("get_children"):
		for c in call_deferred("get_children"):
			placed_rooms.clear()
			c.queue_free()
	if room_scenes.is_empty():
		print("No preset rooms assigned!")
		return

	# Place first room at (0, 0, 0)
	var root_room = await place_first_room(start_scene)
	if not root_room:
		return
	
	var room_queue = [root_room]

	while room_queue.size() > 0 and placed_rooms.size() < max_rooms:
		var rand = randi_range(0,room_queue.size()-1)
		var current_room = room_queue.pop_at(rand)
		for existing_door in current_room.doors:
			if (debug):
				await gen_next
			if placed_rooms.size() < max_rooms:
				var new_room_scene = room_scenes.pick_random()
				var new_room_instance = await try_place_room(existing_door, new_room_scene)
				if new_room_instance:
					room_queue.append(new_room_instance)
					print(str(placed_rooms.size()) + "/" + str(max_rooms))
					
	fill_doors()
	spawn_ores()
	Player.chara.global_position = drill_ship.player_spawn.global_position


func place_first_room(room_scene: PackedScene) -> RoomInstance:
	var room = room_scene.instantiate()
	add_child.call_deferred(room)  # Defer adding the room to the scene tree
	
	# Wait until the next frame to ensure the room has been added to the scene tree
	await get_tree().process_frame  # Await for the next frame
	
	# Now it's safe to access global_transform
	var size = get_room_size(room)
	room.global_transform.origin = Vector3.ZERO  # Place at the center

	var room_data = RoomInstance.new(room, size)
	placed_rooms.append(room_data)
	print(str(placed_rooms.size()) + "/" + str(max_rooms))
	return room_data


func try_place_room(existing_door_transform: Transform3D, room_scene: PackedScene) -> RoomInstance:
	var rotations = [0, 90, 180, 270]
	for angle in rotations:
		var new_room = room_scene.instantiate()
		add_child.call_deferred(new_room)
		await get_tree().process_frame
		# Rotate before checking alignment
		new_room.rotate_y(deg_to_rad(angle))

		# Get room size
		var size = get_room_size(new_room)
		# Find a door that aligns
		for new_door_num in new_room.find_child("Doors").get_children().size():
			var rand: int = randi_range(1,new_room.find_child("Doors").get_children().size()-new_door_num)
			var new_door = new_room.find_child("Doors").get_children().get(rand-1)
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
				if await is_valid_position(room_data):
					
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
		if await aabb_collision_check(placed_room, room_data):
			return false  # Prevent overlapping
	return true

# Check if two rooms are colliding using AABB with rotation support.
func aabb_collision_check(room1: RoomInstance, room2: RoomInstance) -> bool:
	var box1_min:Vector3 = get_box_min(room1.position+room1.offset,room1.size-Vector3(0.00001,0.00001,0.00001))
	var box2_min:Vector3 = get_box_min(room2.position+room2.offset,room2.size-Vector3(0.00001,0.00001,0.00001))
	var box1_max:Vector3 = get_box_max(room1.position+room1.offset,room1.size-Vector3(0.00001,0.00001,0.00001))
	var box2_max:Vector3 = get_box_max(room2.position+room2.offset,room2.size-Vector3(0.00001,0.00001,0.00001))
	if (debug):
		await  gen_next
	return (
		box1_min.x <= box2_max.x && box1_max.x >= box2_min.x\
		&& box1_min.y <= box2_max.y && box1_max.y >= box2_min.y\
		&& box1_min.z <= box2_max.z && box1_max.z >= box2_min.z
 	);

func get_box_min(corner_pos,size) -> Vector3:
	return corner_pos - (size*.5)
func get_box_max(corner_pos,size) -> Vector3:
	return corner_pos + (size*.5)
func print_debug_map():
	for room in placed_rooms:
		print("Room:")
		print("  Room at ", room.position, " size: ", room.size, " rotation Y: ", rad_to_deg(room.node.rotation.y))
		print("  Doors for room:")
		for door in room.doors:
			print("    Door at ", door.origin)

func _ready():
	if debug:
		loading.visible = false
	thread = Thread.new()
	thread.start(generate_dungeon)

func fill_doors():
	for room:RoomInstance in placed_rooms:
		for door_e in room.node.get_doors():
			var door:Marker3D = door_e.get("node")
			var connected = false
			for room_2:RoomInstance in placed_rooms:
				if room_2!=room:
					for door2_e in room_2.node.get_doors():
						var door2:Marker3D = door2_e.get("node")
						if(door.global_position.distance_to(door2.global_position) <=0.01):
							connected = true
			if !connected:
				var door_fill = door_fill_scene.instantiate()
				door.add_child(door_fill)
				await get_tree().process_frame
				door_fill.global_position = door.global_position

func spawn_ores():
	for room:RoomInstance in placed_rooms:
		for marker:Marker3D in room.node.get_ores():
			var new_ore:mineable = preload("res://util/objects/mineable_object.tscn").instantiate()
			new_ore.max_progress = 10
			randomize()
			var ore:Ores.ores = Ores.ores.values().pick_random()
			new_ore.ore = ore
			marker.add_child(new_ore)
			print(new_ore.ore)
			await get_tree().process_frame
			new_ore.global_rotation = marker.global_rotation
			new_ore.global_position = marker.global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		gen_next.emit()
