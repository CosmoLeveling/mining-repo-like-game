extends Node3D
@onready var drill_ship: Drill = $DrillShip

func _ready() -> void:
	MainCanvas.find_child("StartGui").visible=true
	drill_ship._open_close()
