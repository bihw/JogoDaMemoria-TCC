extends Control

@onready var label: Label = $Panel/TextureRect/Label
@onready var label_2: Label = $Panel/TextureRect/Label2
@onready var label_3: Label = $Panel/TextureRect/Label3

var text: String = ""
var text2: String = ""
var text3: String = ""


func _ready() -> void:
	if text != "":
		label.visible = true
		label_2.visible = false
		label_3.visible = false
		label.text = text
	else:
		label.visible = false
		label_2.visible = true
		label_3.visible = true
		label_2.text = text2
		label_3.text = text3


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var in_colorrect = $Panel.get_global_rect().has_point(mouse_pos)
		var in_textrect = $Panel/TextureRect.get_global_rect().has_point(mouse_pos)
		if in_colorrect and not in_textrect:
			queue_free()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		queue_free()


func _on_close_button_pressed() -> void:
	queue_free()
