class_name MovementInputComponent
extends Resource

func get_movement_input() -> Vector2:
	var movement_direction:Vector2 = Input.get_vector("left","right","up","down")
	
	return movement_direction


func get_sprint_input() -> bool:
	return Input.is_action_pressed("sprint")

func get_jump_input() -> bool:
	return Input.is_action_just_pressed("jump")
