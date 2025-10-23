extends Control

@onready var label: Label = $ColorRect/TextRect/Label
@onready var button_1: Button = $ColorRect/TextRect/VBoxContainer/Button1
@onready var button_2: Button = $ColorRect/TextRect/VBoxContainer/Button2
@onready var button_3: Button = $ColorRect/TextRect/VBoxContainer/Button3
@onready var back_button: TextureButton = $ColorRect/BackButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var pause: bool
var options_open = false


func _ready() -> void:
	if pause:
		$ColorRect/TextRect/AnimatedSprite2D.visible = false
		process_mode = Node.PROCESS_MODE_ALWAYS
		back_button.visible = true
		label.text = "PAUSE"
		button_1.connect("pressed", self._on_new_game_button_pressed)
		button_1.text = "NOVO JOGO"
		button_2.connect("pressed", self._on_options_button_pressed)
		button_2.text = "OPÇÕES"
		button_3.connect("pressed", self._on_home_button_pressed)
		button_3.text = "TELA INICIAL"
		$ColorRect/BackButton.visible = true
		$ColorRect/BackButton.connect("pressed", _on_back_button_pressed)
	else:
		if Save.saved.victory_music:
			play_music()
		else:
			$ColorRect/TextRect/AnimatedSprite2D.visible = true
		get_parent().finished_lvl = true
		back_button.visible = false
		label.text = "VOCÊ VENCEU"
		if Global.lvl == 3:
			button_1.connect("pressed", self._on_new_game_button_pressed)
			button_1.text = "NOVO JOGO"
		else:
			button_1.connect("pressed", self._on_next_button_pressed)
			button_1.text = "PRÓXIMA FASE"
		button_2.connect("pressed", self._on_home_button_pressed)
		button_2.text = "TELA INICIAL"
		button_3.connect("pressed", self._on_quit_button_pressed)
		button_3.text = "SAIR"


func play_music():
	$ColorRect/TextRect/AnimatedSprite2D.visible = true
	var tween = get_tree().create_tween()
	MusicPlayer.tween = tween
	MusicPlayer.turn_up_down(-10)
	var path = "res://assets/sound_effects/victory.mp3"
	audio_stream_player.stream = load(path)
	audio_stream_player.finished.connect(_on_music_finished)
	audio_stream_player.play()


func _on_music_finished():
	var tween = get_tree().create_tween()
	MusicPlayer.tween = tween
	MusicPlayer.turn_up_down(0) 
	audio_stream_player.finished.disconnect(_on_music_finished)


func _input(event):
	if pause and event is InputEventMouseButton and event.pressed and not options_open:
		var mouse_pos = get_viewport().get_mouse_position()
		var in_button = $ColorRect/BackButton.get_global_rect().has_point(mouse_pos)
		var in_colorrect = $ColorRect.get_global_rect().has_point(mouse_pos)
		var in_textrect = $ColorRect/TextRect.get_global_rect().has_point(mouse_pos)
		if in_colorrect and not in_textrect and not in_button:
			call_deferred("_on_back_button_pressed")


func _on_new_game_button_pressed() -> void:
	if pause:
		# jogo nao foi finalizado
		get_tree().paused = false
	Global.lvl = 1
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_home_button_pressed() -> void:
	if pause:
		get_tree().paused = false
		get_parent().finish()
	get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func on_options_back_pressed(options_instance: Node):
	options_instance.queue_free()


func _on_options_button_pressed() -> void:
	options_open = true
	var options_instance = load("res://scenes/settings_scene.tscn").instantiate() 
	add_child(options_instance)
	if pause: 
		options_instance.back_pressed.connect(on_options_back_pressed.bind(options_instance))
	else:
		options_instance.back_home = true


func _on_next_button_pressed():
	if Global.lvl < 3:
		Global.lvl += 1
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_back_button_pressed() -> void:
	get_parent()._toggle_pause()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if pause:
			get_parent()._toggle_pause()
		else:
			get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")
