extends CanvasLayer
signal done_loading
@onready var progress_bar: ProgressBar = $Panel/ProgressBar
@onready var map_generation: MapGenerator = %MapGeneration
var loading = true

func _process(_delta: float) -> void:
	if loading:
		if not 100*(map_generation.placed_rooms.size()/float(map_generation.max_rooms))==100:
			var tween:Tween= create_tween()
			tween.tween_property(progress_bar,"value",int(100*(map_generation.placed_rooms.size()/float(map_generation.max_rooms))),1)
		if 100*(map_generation.placed_rooms.size()/float(map_generation.max_rooms)) >= 100:
			loading = false
			await get_tree().create_timer(1.5).timeout
			visible = false
			done_loading.emit()
