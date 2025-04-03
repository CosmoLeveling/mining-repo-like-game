class_name mineable
extends StaticBody3D

@export var drop_scene: PackedScene
var progress : int = 0
@export var max_progress : int = 0

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
		drop.get_node("SellableComponent").cost = randi_range(100,200000)
	get_parent().add_child(drop)
	drop.global_position = global_position

func tween_finished():
	var tween : Tween = create_tween()
	tween.tween_property(self,"scale",Vector3(1,1,1),0.05)
