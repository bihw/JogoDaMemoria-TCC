extends Button

@export var main: Node
@export var card_image: Texture2D

@onready var back_image_node: TextureRect = $BackImage
@onready var image: TextureRect = $Image
@onready var label: Label = $Label

var back_image: Texture2D = preload("res://assets/back_card.png")
var flipped: bool = false
var found: bool = false
var lab: String  # label
var h: float = 145
var w: float = 110


func _ready():
	image.texture = null
	back_image_node.texture = back_image
	custom_minimum_size = Vector2(w, h)


func _process(delta: float) -> void:
	if found and image.texture != null:
		await get_tree().create_timer(1).timeout
		label.visible = false
		back_image_node.texture = null
		image.texture = null
		disabled = true
		theme = null
		add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func adjust_font(l: Label) -> void:
	var font_size = l.get_theme_font_size("font")
	
	if image.texture.resource_path.get_file().get_basename() == "jacaré-fêmea" or image.texture.resource_path.get_file().get_basename() == "jacaré-macho":
		font_size = 18 if Global.lvl == 2 else 16 
	else:
		font_size = 21 if Global.lvl == 2 else 20
	
	l.add_theme_font_size_override("font_size", font_size)


func _on_pressed() -> void:
	if not found and not flipped:
		flip_card()
		if label.visible and Global.lvl != 1:
			adjust_font(label)


func flip_card():
	get_parent().get_parent().get_parent().get_parent().click_card_register()
	if flipped:
		image.texture =  null
		label.visible = false
		back_image_node.texture = back_image 
	else:
		image.texture = card_image
		back_image_node.texture = null
		label.visible = true
		label.text = lab
		main.add_flipped_card(self) 
		#var parent = get_parent().get_parent().get_parent().get_parent()
		#parent.get_node("Glow").visible = false
	flipped = not flipped
