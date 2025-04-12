class_name SaveGame
extends Resource

const SAVES_PATH := "user://saves"
const SecurityKey := "123pwqpeo1"

@export var money:int
@export var items:Array[String]

func write_savegame(save_name:String) -> void:
	var file = FileAccess.open_encrypted_with_pass(SAVES_PATH+"/"+save_name+".save",FileAccess.WRITE,SecurityKey)
	if file == null:
		print(FileAccess.get_open_error())
		return
	var new:Array[String] = ["tree"]
	var data = {
		"money":1000, 
		"items":new
	}
	var json_string = JSON.stringify(data,"\t")
	file.store_string(json_string)
	file.close()
static func load_saves() -> Array[String]:
	var saves: Array[String] = []
	var dir = DirAccess.open(SAVES_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				saves.append(file_name.trim_suffix(".save"))
			file_name = dir.get_next()
	else:
		print("An error occured when trying to access the path")
	return saves

static func load_save(save_name:String) -> SaveGame:
	if FileAccess.file_exists(SAVES_PATH+"/"+save_name+".save"):
		var file = FileAccess.open_encrypted_with_pass(SAVES_PATH+"/"+save_name+".save",FileAccess.READ,SecurityKey)
		if file == null:
			print(FileAccess.get_open_error())
			return
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse %s as a json_string: (%s)" % [SAVES_PATH+"/"+save_name+".save",content])
			return
		var GameData = SaveGame.new()
		GameData.money = data.money
		for i in data.items:
			GameData.items.append(i)
		return GameData
	else:
		printerr("Cannot open non-existent file at %s!" % [SAVES_PATH+"/"+save_name+".save"])
		return null
