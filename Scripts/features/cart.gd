class_name Cart
extends PickupableItem
@onready var area_3d: Area3D = $Area3D
@onready var label_3d: Label3D = $Label3D
@export var hover_height: float = 2.0
@export var stiffness: float = 1000.0
@export var damping_ratio: float = 1.0
@export var friction_strength: float = 10.0

@onready var raycasts := [
	$RayCast3D_Left,
	$RayCast3D_Right,
	$RayCast3D_Front,
	$RayCast3D_Back
]
func _process(_delta: float) -> void:
	var cost:int = 0
	for body in area_3d.get_overlapping_bodies():
		if body.has_node("SellableComponent"):
			var sellable_comp:SellableComponent = body.get_node("SellableComponent")
			cost += sellable_comp.cost
	label_3d.text = str(cost)

func _physics_process(_delta: float) -> void:
	for raycast in raycasts:
		if raycast.is_colliding():
			var point = raycast.get_collision_point()
			var world_pos = raycast.global_transform.origin
			var distance = world_pos.y - point.y
			distance = clamp(distance, 0.0, hover_height * 2)  # Avoid out-of-control values
			var error = hover_height - distance

			var local_velocity = linear_velocity
			var vertical_velocity = local_velocity.y

			# Apply force to stabilize hover height
			var damping = 2.0 * sqrt(stiffness*mass) * damping_ratio
			var force = (error * stiffness) - (vertical_velocity * damping)
			apply_force(Vector3.UP * force, world_pos - global_transform.origin)

	# 🪄 Special detection for slopes
	if is_being_pulled() and $RayCast3D_Front.is_colliding():
		var normal = $RayCast3D_Front.get_collision_normal()

		# If the slope is steep (greater than 45 degrees or more), apply more force
		if normal.y < 0.5:  # Adjust this threshold based on your needs
			apply_central_force(Vector3.UP * 300.0)  # Stronger force to lift cart

	# Apply friction on horizontal movement
	var horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	var friction_force = -horizontal_velocity * friction_strength
	apply_central_force(friction_force)

	apply_rotation_towards(Vector3(0, global_rotation.y, 0))  # Keep rotation aligned


func is_being_pulled() -> bool:
	# You can modify this condition to check if the player is dragging it
	# For example, by comparing the distance between the cart and pickup location, or checking the speed
	return linear_velocity.length() > 0.5

func apply_rotation_towards(target_global_rotation: Vector3, 
		torque_strength: float = 1000.0, damping: float = 100.0):
	var current_quat = Quaternion.from_euler(global_rotation)
	var target_quat
	target_quat = Quaternion.from_euler(target_global_rotation)
	var delta_quat = target_quat * current_quat.inverse()
	
	if delta_quat.w < 0:
		delta_quat = -delta_quat
	
	var angle = 2.0 * acos(clamp(delta_quat.w, -1.0, 1.0))
	var axis = delta_quat.get_axis() if angle > 0.0001 else Vector3.ZERO
	
	var torque = axis * angle * torque_strength - angular_velocity * damping
	apply_torque(torque)
