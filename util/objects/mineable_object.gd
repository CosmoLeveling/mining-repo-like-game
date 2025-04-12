class_name mineable
extends StaticBody3D

@export var drop_scene: PackedScene
var progress : int = 0
@export var max_progress : int = 0
@onready var node_3d: Node3D = $Node3D
@export var ore:Ores.ores
@onready var ores: Node3D = $ores

func _ready() -> void:
	for c in ores.get_children():
		if c is MeshInstance3D:
			var v:MeshInstance3D = c
			var mat:StandardMaterial3D = v.get_surface_override_material(0).duplicate()
			mat.albedo_color = Ores.get_color_for_ore(ore)
			c.set_surface_override_material(0,mat)

func interact():
	if progress == max_progress:
		spawn_drop()
		queue_free()
	else:
		var tween : Tween = create_tween()
		tween.finished.connect(tween_finished)
		tween.tween_property(self,"scale",Vector3(1.25,1.25,1.25),0.05)
		progress += 1

func spawn_drop():
	var drop = drop_scene.instantiate()
	if drop.has_node("SellableComponent"):
		drop.get_node("SellableComponent").cost = randi_range(100,20000)
	get_parent().get_parent().get_parent().add_sibling(drop)
	drop.global_position = node_3d.global_position

func tween_finished():
	var tween : Tween = create_tween()
	tween.tween_property(self,"scale",Vector3(1,1,1),0.05)
