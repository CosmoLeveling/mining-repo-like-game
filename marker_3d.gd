extends CharacterBody3D

const mouse_sensitivity : float = 0.05
@onready var head_pivot: Node3D = $HeadPivot
@onready var interaction: RayCast3D = $HeadPivot/Camera3D/Interaction
@onready var pickup_location: Marker3D = $HeadPivot/Camera3D/PickupLocation

@onready var movement_input_component : MovementInputComponent = MovementInputComponent.new()
@export var movement_component : MovementComponent = null

var picked_object : PickupableItem
var pull_power : int = 4

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	
	movement_component.handle_movement_state()
	movement_component.handle_acceleration(self,movement_input_component.get_movement_input())
	movement_component.handle_jump(self,movement_input_component.get_jump_input())
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = pickup_location.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)
	
	move_and_slide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("lmouse"):
		if picked_object == null:
			handle_interact()
		elif picked_object != null:
			handle_drop()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head_pivot.rotation.x = clamp(head_pivot.rotation.x,deg_to_rad(-80),deg_to_rad(80))
	
	movement_component.set_movement_state(movement_input_component.get_sprint_input())

func handle_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		

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
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
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
