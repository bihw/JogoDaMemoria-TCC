extends Control


func _on_back_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		ScreenTransition.transition()
		await ScreenTransition.transitioned_halfway
		get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")
