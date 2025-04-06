class_name Cart
extends RigidBody3D


var current_speed:int = 0
@export var flipped: bool
@export var height_adjustment:float = 1
@export var point: TrackFollower
@onready var label_3d: Label3D = $CollisionShape3D6/Label3D

func _physics_process(_delta: float) -> void:
	label_3d.text = str(current_speed)
	if point:
		var adjustment_vector:Vector3 = Vector3(0,height_adjustment,0)
		apply_rotation_towards(point.global_transform.origin+adjustment_vector,point.global_rotation)
func apply_rotation_towards(target_position: Vector3, target_global_rotation: Vector3, 
							 torque_strength: float = 1000.0, damping: float = 100.0, 
							 move_strength: float = 500.0, move_damping: float = 50.0):
	var current_quat = Quaternion.from_euler(global_rotation)
	var target_quat
	if flipped:
		target_quat = Quaternion.from_euler(target_global_rotation+Vector3(0,deg_to_rad(180),0))
	else:
		target_quat = Quaternion.from_euler(target_global_rotation)
	var delta_quat = target_quat * current_quat.inverse()
	
	if delta_quat.w < 0:
		delta_quat = -delta_quat
	
	var angle = 2.0 * acos(clamp(delta_quat.w, -1.0, 1.0))
	var axis = delta_quat.get_axis() if angle > 0.0001 else Vector3.ZERO
	
	var torque = axis * angle * torque_strength - angular_velocity * damping
	apply_torque(torque)
	
	var position_error = target_position - global_transform.origin
	var velocity_error = linear_velocity
	var force = position_error * move_strength - velocity_error * move_damping
	apply_central_force(force)


func _on_up_interact() -> void:
	current_speed += 1

func _on_down_interact() -> void:
	current_speed -= 1

func _on_switch_interact() -> void:
	pass
