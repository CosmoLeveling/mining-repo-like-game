class_name Cart
extends PickupableItem
@onready var area_3d: Area3D = $Area3D
@onready var label_3d: Label3D = $Label3D

func _process(delta: float) -> void:
	var cost:int = 0
	for body in area_3d.get_overlapping_bodies():
		if body.has_node("SellableComponent"):
			var sellable_comp:SellableComponent = body.get_node("SellableComponent")
			cost += sellable_comp.cost
	label_3d.text = str(cost)

func _physics_process(_delta: float) -> void:
	apply_rotation_towards(Vector3(0,global_rotation.y,0))
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
