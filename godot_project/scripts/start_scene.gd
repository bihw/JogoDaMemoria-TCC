extends Control


func _ready() -> void:
	Save.load_save()


func _on_start_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_options_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	var options_instance = load("res://scenes/settings_scene.tscn").instantiate() 
	$Control/VBoxContainer/Options.release_focus()
	add_child(options_instance)
	options_instance.texture_back = null
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))


func on_options_closed(options_instance: Node):
	options_instance.queue_free()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()


func _on_doubts_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/doubts_scene.tscn")


func _on_info_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/info_scene.tscn")


func _on_statistics_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/statistics_scene.tscn")
