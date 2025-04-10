class_name SaveGame
extends Resource

const SAVES_PATH := "user://saves"

@export var money:int
@export var items:Array[String]

func write_savegame(save_name:String) -> void:
	ResourceSaver.save(self,SAVES_PATH+"/"+save_name+".tres")

static func load_saves() -> Array[String]:
	var saves: Array[String] = []
	var dir = DirAccess.open(SAVES_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				saves.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occured when trying to access the path")
	return saves

static func load_save(save_file:String) -> SaveGame:
	if ResourceLoader.exists(SAVES_PATH+"/"+save_file):
		return ResourceLoader.load(SAVES_PATH+"/"+save_file)
	return null
