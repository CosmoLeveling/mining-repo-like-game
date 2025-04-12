class_name Drill
extends Node3D
signal button_clicked
@onready var anim: AnimationPlayer = $AnimatableBody3D/AnimationPlayer
@onready var player_spawn: Marker3D = $PlayerSpawn

@export var open = true
func _open_close():
	if open:
		open=false
		anim.play_backwards("open")
	else:
		open=true
		anim.play("open")


func _on_interaction_area_interact() -> void:
	button_clicked.emit()
