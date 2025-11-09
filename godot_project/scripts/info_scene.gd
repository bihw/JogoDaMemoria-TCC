# ========================================================
# IDENTIFICAÇÃO DE AUTORIA
# Bianca Herrmann Waskow
# Graduanda pela Universidade Federal de Pelotas - UFPel
# Desenvolvedora integral do aplicativo
# CPF: 04232108076
# E-mail: bhwaskow@gmail.com
# ========================================================

extends Control

@onready var back_button: TextureButton = $TextureRect/ColorRect/BackButton


func _on_back_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var in_button = back_button.get_global_rect().has_point(mouse_pos)
		var in_colorrect = $TextureRect/ColorRect.get_global_rect().has_point(mouse_pos)
		var in_textrect = $TextureRect/ColorRect/TextureRect.get_global_rect().has_point(mouse_pos)
		if in_colorrect and not in_textrect and not in_button:
			call_deferred("_on_back_button_pressed")


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		ScreenTransition.transition()
		await ScreenTransition.transitioned_halfway
		get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")
