extends PickupableItem

@export var path_follow: PathFollow3D
@export var correction_strength: float = 10.0

var progress_position := 0.0

func _ready():
	if path_follow:
		progress_position = path_follow.progress

func _process(delta: float) -> void:
	print(path_follow.progress)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not path_follow:
		return

	var current_position = global_transform.origin

	# Set PathFollow to current progress
	path_follow.progress = progress_position
	var path_position = path_follow.global_transform.origin

	# Estimate path tangent
	var delta := 0.1
	path_follow.progress = progress_position + delta
	var ahead_position = path_follow.global_transform.origin
	var tangent := (ahead_position - path_position).normalized()
	path_follow.progress = progress_position  # Reset it

	# Decompose the body's current velocity into:
	# - movement along the path (projected on the tangent)
	# - and perpendicular to the path (which we’ll remove)
	var velocity = state.linear_velocity
	var speed_along_path = velocity.dot(tangent)
	var corrected_velocity = tangent * speed_along_path
	state.linear_velocity = corrected_velocity  # Only move along the path

	# Update the progress value based on this velocity
	progress_position += speed_along_path * state.step

	# Calculate position correction force to pull it back onto the path
	path_follow.progress = progress_position
	var corrected_position = path_follow.global_transform.origin
	var position_offset = corrected_position - current_position
	var correction_force = position_offset * correction_strength

	state.apply_force(correction_force)
