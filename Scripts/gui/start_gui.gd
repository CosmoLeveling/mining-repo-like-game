extends Control


func _on_singleplayer_pressed() -> void:
	MainCanvas.find_child("GameChooseMenu").visible = true
	visible = false
