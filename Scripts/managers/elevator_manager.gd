extends Node3D

var Floor = 0
var max_floor = 1
var min_floor = 0
@export var elevator:PathFollow3D

func _physics_process(_delta: float) -> void:
	if Floor>0:
		elevator.progress+=3*_delta
	else:
		elevator.progress-=3*_delta
func Up():
	if Floor<max_floor:
		Floor+=1
func Down():
	if Floor>min_floor:
		Floor-=1
