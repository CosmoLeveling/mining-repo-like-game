extends Control

var single_player:bool = true
@export var save_scene: PackedScene
@onready var save_parent: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/ScrollContainer/MarginContainer/SaveParent

func _ready() -> void:
	_on_load_pressed()

func _on_button_pressed() -> void:
	var save:SaveGame = SaveGame.new()
	save.money = 10000
	save.items = ["tree"]
	save.write_savegame("purple")


func _on_load_pressed() -> void:
	for c in save_parent.get_children():
		c.queue_free()
	for i in SaveGame.load_saves():
		var save_instance:SaveTemplate = save_scene.instantiate()
		save_instance.save_file = i
		save_parent.add_child(save_instance)
