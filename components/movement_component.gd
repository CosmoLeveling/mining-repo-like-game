class_name MovementComponent
extends Node

@export var base_speed : float = 5.0
@export var sprint_speed : float = 8.0
@export var jump_height : float = 6.5

var current_speed : float = 0.0

enum movement_states {Neutral, Sprinting}

var current_movement_state : movement_states = movement_states.Neutral


func handle_movement_state() -> void:
	match current_movement_state:
		movement_states.Neutral:
			current_speed = base_speed
		movement_states.Sprinting:
			current_speed = sprint_speed

func set_movement_state(is_sprinting : bool):
	if is_sprinting:
		current_movement_state = movement_states.Sprinting
	else:
		current_movement_state = movement_states.Neutral

func handle_acceleration(entity : CharacterBody3D, target_dir : Vector2) -> void:
	var dir : Vector3 = (entity.transform.basis * Vector3(target_dir.x, 0, target_dir.y))
	
	dir.normalized()
	
	if dir:
		entity.velocity.x = dir.x * current_speed
		entity.velocity.z = dir.z * current_speed
	else:
		entity.velocity.x = move_toward(entity.velocity.x, 0, current_speed)
		entity.velocity.z = move_toward(entity.velocity.z, 0, current_speed)

func handle_jump(entity : CharacterBody3D, is_jumping : bool) -> void:
	if is_jumping and entity.is_on_floor():
		entity.velocity.y = jump_height
