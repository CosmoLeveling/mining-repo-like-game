class_name SaveTemplate
extends Panel
@onready var save_file_label: Label = $MarginContainer/HBoxContainer/SaveFile

var save_file: String

func _ready() -> void:
	save_file_label.text = save_file


func _on_load_pressed() -> void:
	var save = SaveGame.load_save(save_file)
	if save == null:
		queue_free()
		return
	GameManager.gameData = save
	MainCanvas.find_child("GameChooseMenu").visible = false
	var loadingScreen = load("res://Scenes/gui/Loading.tscn")
	GameManager.next_scene = "res://Scenes/main_scenes/team_hub.tscn"
	get_tree().change_scene_to_packed(loadingScreen)
