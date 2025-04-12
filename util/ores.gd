extends Node

enum ores{
	Iron,
	Gold,
	Uranium
}

func get_color_for_ore(ore : ores):
	match ore:
		ores.Iron:
			return Color("401200")
		ores.Gold:
			return Color("FFD700")
		ores.Uranium:
			return Color("00FF00")
