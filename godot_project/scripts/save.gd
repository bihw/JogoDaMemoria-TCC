extends Node

var saved = SettingsData
const SAVE_PATH = "user://save_resources.tres"


func _ready() -> void:
	load_save()


func save():
	ResourceSaver.save(saved, SAVE_PATH)


func load_save():
	if ResourceLoader.exists(SAVE_PATH):
		saved = ResourceLoader.load(SAVE_PATH).duplicate(true)
	else:
		saved = SettingsData.new()
