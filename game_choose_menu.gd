extends Control

var single_player:bool = true


func _on_button_pressed() -> void:
	var save:SaveGame = SaveGame.new()
	save.money = 1000
	save.items = ["tree"]
	save.write_savegame()


func _on_load_pressed() -> void:
	var save:SaveGame = SaveGame.load_savegame()
	print(save.money)
	print(save.items)
