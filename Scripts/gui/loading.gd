extends Control

var progress = []
var scene_load_status = 0
@onready var progress_bar: ProgressBar = $Panel/ProgressBar

func _ready() -> void:
	ResourceLoader.load_threaded_request(GameManager.next_scene)

func _process(_delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(GameManager.next_scene,progress)
	progress_bar.value = progress[0]
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(GameManager.next_scene)
		get_tree().change_scene_to_packed(newScene)
