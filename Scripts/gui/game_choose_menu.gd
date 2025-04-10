extends Control

var single_player:bool = true


func _on_button_pressed() -> void:
	var save:SaveGame = SaveGame.new()
	save.money = 10000
	save.items = ["tree"]
	save.write_savegame("purple")


func _on_load_pressed() -> void:
	print("Saves: ")
	for i in SaveGame.load_saves():
		var save = SaveGame.load_save(i)
		print(save.items)
		print(save.money)
