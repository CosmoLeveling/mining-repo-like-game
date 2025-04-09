class_name player
extends Node3D

const MAX_STEP_HEIGHT : float= 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF
const mouse_sensitivity : float = 0.1
@onready var visuals: Node3D = $Visuals
@onready var chara: CharacterBody3D = $CharacterBody3D
@onready var head_pivot: Node3D = $CharacterBody3D/HeadPivot
@onready var interaction: RayCast3D = $CharacterBody3D/HeadPivot/Camera3D/Interaction
@onready var pickup_location: Marker3D = $CharacterBody3D/HeadPivot/Camera3D/PickupLocation

@onready var movement_input_component : MovementInputComponent = MovementInputComponent.new()
@export var movement_component : MovementComponent = null

var picked_object : PickupableItem
var pull_power : int = 4

func _physics_process(delta: float) -> void:
	if chara.is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	
	handle_gravity(delta)
	
	movement_component.handle_movement_state()
	movement_component.handle_acceleration(chara,movement_input_component.get_movement_input())
	movement_component.handle_jump(self,movement_input_component.get_jump_input())
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = pickup_location.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)
	if not _snap_up_stairs_check(delta):
		chara.move_and_slide()
		_snap_down_to_stairs_check()

func _process(_delta: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(visuals,"global_position",chara.global_position,0.01)
	
	if Input.is_action_just_pressed("lmouse"):
		if picked_object == null:
			handle_interact()
		elif picked_object != null:
			handle_drop()

func _snap_up_stairs_check(delta) -> bool:
	if not chara.is_on_floor() and not _snapped_to_stairs_last_frame: return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if chara.velocity.y > 0 or (chara.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = chara.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = chara.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))

	var down_check_result = KinematicCollision3D.new()
	if (chara.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - chara.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - chara.global_position).y > MAX_STEP_HEIGHT: return false
		$CharacterBody3D/StairsAheadRaycast3D.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		$CharacterBody3D/StairsAheadRaycast3D.force_raycast_update()
		if $CharacterBody3D/StairsAheadRaycast3D.is_colliding() and not is_surface_too_steep($CharacterBody3D/StairsAheadRaycast3D.get_collision_normal()):
			chara.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			chara.apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below : bool = $CharacterBody3D/StairsBelowRaycast3d.is_colliding() and not is_surface_too_steep($CharacterBody3D/StairsBelowRaycast3d.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not chara.is_on_floor() and chara.velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(chara.global_transform,Vector3(0,-MAX_STEP_HEIGHT,0),body_test_result):
			var translate_y = body_test_result.get_travel().y
			chara.position.y+=translate_y
			chara.apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		chara.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head_pivot.rotation.x = clamp(head_pivot.rotation.x,deg_to_rad(-80),deg_to_rad(80))
	
	movement_component.set_movement_state(movement_input_component.get_sprint_input())

func handle_gravity(delta : float) -> void:
	if not chara.is_on_floor():
		chara.velocity += chara.get_gravity() * delta
		

func handle_drop():
	if picked_object != null:
		picked_object = null

func handle_interact():
	var collider = interaction.get_collider()
	if collider != null:
		if collider is PickupableItem:
			var pickupable_object : PickupableItem = collider
			picked_object = pickupable_object
			if pickupable_object.has_node("SellableComponent"):
				var sellable_component: SellableComponent = pickupable_object.get_node("SellableComponent")
				print("Cost: " + str(sellable_component.cost))
				print("Rarity: " + str(sellable_component.rarity))
		elif collider is mineable:
			var mineable_object : mineable = collider
			mineable_object.interact()
		elif collider is InteractionArea:
			var interactionArea : InteractionArea = collider
			interactionArea.interact.emit()

func _push_away_rigid_bodies():
	for i in chara.get_slide_collision_count():
		var c := chara.get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			if mass_ratio < 0.25:
				continue
			push_dir.y = 0
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

func _run_body_test_motion(from:Transform3D,motion:Vector3,result = null) -> bool:
	if not result: result = PhysicsTestMotionParameters3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(chara.get_rid(),params,result)

func is_surface_too_steep(normal:Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > chara.floor_max_angle
