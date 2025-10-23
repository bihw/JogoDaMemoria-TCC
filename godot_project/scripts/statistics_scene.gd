extends Control

@onready var button: Button = $TextureRect/ColorRect/TextureRect/Button
@onready var label_nenhuma: Label = $TextureRect/ColorRect/TextureRect/LabelNenhuma
@onready var label: Label = $TextureRect/ColorRect/TextureRect/Label
@onready var label_2: Label = $TextureRect/ColorRect/TextureRect/Label2
@onready var label_e_1: Label = $TextureRect/ColorRect/TextureRect/LabelE1
@onready var label_e_2: Label = $TextureRect/ColorRect/TextureRect/LabelE2
@onready var label_titulo: Label = $TextureRect/ColorRect/TextureRect/LabelTitulo
@onready var back_button: TextureButton = $TextureRect/ColorRect/BackButton


func _ready() -> void:
	if Global.date_f != null:
		label_titulo.visible = true
		label_e_1.text = 'Nome: %s\nData: %s\nHorário de início: %s' % [Global.current_name, Global.date_f, Global.time_f]
		
		label_e_2.text = 'Finalizado: %s\nNível: %s\nDuração: %s\nErros: %s\nAcertos: %s
Acertos consecutivos: %s\nDemorou demais: %s\nMuitos cliques: %s
Carta mais errada: %s\nPar mais errado: %s' % [Global.finished_lvl, Global.lvl, Global.duration, 
Global.miss, Global.hit, Global.consecutive_hits, Global.long_time, Global.several_clicks, 
Global.most_frequent_card, Global.most_frequent_pair.replace("\"", "")]
		
		button.visible = true
	else:
		button.visible = false
		label.visible = true
		label_2.visible = true
		label_nenhuma.visible = true
		label_titulo.visible = false


func _on_back_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
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


func _on_button_pressed() -> void:
	var warning_instance = load("res://scenes/components_prefabs/warning_panel.tscn").instantiate() 
	warning_instance.text2 = "Dirija-se ao seu\narmazenamento interno: "
	warning_instance.text3 = "Documents/Jogo da Memória/\ndados.csv"
	add_child(warning_instance)
