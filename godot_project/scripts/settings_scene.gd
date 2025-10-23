extends Control

signal back_pressed

@onready var texture_back: TextureRect = $TextureBack
@onready var back_button: TextureButton = $ColorRect/BackButton
@onready var enter_button: TextureButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/NameVBoxContainer/LEditTextureRect/MarginContainer/EnterButton
@onready var name_line_edit: LineEdit = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/NameVBoxContainer/LEditTextureRect/MarginContainer/NameLineEdit
@onready var texture_rect: TextureRect = $ColorRect/TextureRect

var back_home: bool = false


func _ready() -> void:
	if Global.current_name != "" and Global.current_name != "undefined":
		name_line_edit.text = Global.current_name
	else:
		name_line_edit.text = ""


func _enter_tree():
	Save.load_save()
	
	var music_flag: CheckButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/MusicFlag
	var victory_music_flag: CheckButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/VictoryMusicFlag
	var sfx_flag: CheckButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/SfxFlag
	var warning_flag: CheckButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/WarningFlag
	var clicks_warning_flag: CheckButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/ClicksWarningFlag
	var tips_flag: CheckButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/TipsFlag
	var timer_flag: CheckButton = $ColorRect/TextureRect/ScrollContainer/VBoxContainer/TimerFlag
	
	music_flag.button_pressed = true if Save.saved.music else false
	victory_music_flag.button_pressed = true if Save.saved.victory_music else false
	sfx_flag.button_pressed = true if Save.saved.sfx else false
	warning_flag.button_pressed = true if Save.saved.warning_error else false
	clicks_warning_flag.button_pressed = true if Save.saved.warning_clicks else false
	tips_flag.button_pressed = true if Save.saved.tips else false
	timer_flag.button_pressed = true if Save.saved.timer else false
	


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if get_tree().get_current_scene().name == "GameScene":
			get_parent().options_open = false
		ScreenTransition.transition()
		await ScreenTransition.transitioned_halfway
		if back_home:
			get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")
		else:
			back_pressed.emit()


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var in_button = back_button.get_global_rect().has_point(mouse_pos)
		var in_colorrect = $ColorRect.get_global_rect().has_point(mouse_pos)
		var in_textrect = texture_rect.get_global_rect().has_point(mouse_pos)
		if in_colorrect and not in_textrect and not in_button:
			call_deferred("_on_back_button_pressed")


func _on_back_button_pressed() -> void:
	Save.save()
	if get_tree().get_current_scene().name == "GameScene":
		get_parent().options_open = false
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	if back_home:
		queue_free()
	else:
		back_pressed.emit()


func _on_enter_button_pressed() -> void:
	var name_text = name_line_edit.text.strip_edges()
	if name_text != "":
		Global.current_name = name_text
		var warning_instance = load("res://scenes/components_prefabs/warning_panel.tscn").instantiate() 
		warning_instance.text = "NOME ALTERADO\nCOM SUCESSO"
		add_child(warning_instance)
	else:
		name_line_edit.placeholder_text = "Nome inválido"


func _on_music_flag_toggled(toggled_on: bool) -> void:
	if toggled_on:
		MusicPlayer.play()
		Save.saved.music = true
	else:
		MusicPlayer.stop()
		Save.saved.music = false
	Save.save()


func _on_victory_music_flag_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Save.saved.victory_music = true
	else:
		Save.saved.victory_music = false
	Save.save()


func _on_sfx_flag_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Save.saved.sfx = true
	else:
		Save.saved.sfx = false
	Save.save()


func _on_warning_flag_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Save.saved.warning_error = true
	else:
		Save.saved.warning_error = false
	Save.save()


func _on_clicks_warning_flag_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Save.saved.warning_clicks = true
	else:
		Save.saved.warning_clicks = false
	Save.save()


func _on_timer_flag_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Save.saved.timer = true
	else:
		Save.saved.timer = false
	Save.save()


func _on_tips_flag_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Save.saved.tips = true
	else:
		Save.saved.tips = false
	Save.save()
