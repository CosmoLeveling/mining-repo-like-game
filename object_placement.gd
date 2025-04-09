extends Node3D

@onready var polygon: Array = $Polygon2D.polygon
@onready var n = polygon.size()

var p_radius: int = 1
var k: int = 0
var points := []

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	points = PoissonDiscSampling.generate_points_for_polygon($Polygon2D.polygon, p_radius, 30)
	for point in points:
		var test: MeshInstance3D = MeshInstance3D.new()
		test.mesh = SphereMesh.new()
		add_child(test)
		test.global_position = Vector3(point.x,0,point.y)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_FORCE_QUIT"):
		get_tree().quit()
