extends Control

const CARD_SCENE = preload("res://scenes/components_prefabs/card_button.tscn")
const CARD_IMAGES = [
	["boi", "vaca", 1],
	["cachorro", "cachorra", 2], #["cao"],["cadela"],
	["galo", "galinha", 3],
	["leão", "leoa", 4],
	["gato", "gata", 5],
	["elefante", "elefanta", 6],
	["bode", "cabra", 7],
	["carneiro", "ovelha", 8],
	["pavão", "pavoa", 9],
	["zangão", "abelha", 10],
	["cervo", "cerva", 11],
	["jacaré-macho", "jacaré-fêmea", 12], 
	["tigre", "tigresa", 13],
	["coelho", "coelha", 14],
	["lobo", "loba", 15],
	["raposa", "raposo", 16],
	["peru", "perua", 17],
	["avestruz1", "avestruz2", 18],
	["pato", "pata", 19],
	["javali", "javalina", 20],
	["búfalo", "búfala", 21],
	["cavalo", "égua", 22]
	#["porco"],["porca"], #["leitao"],["leitoa"],
	#["sapo"],["sapa"],
	#["macaco"],["macaca"],
	#["camelo"],["camela"],
	#["dromedaria"],["dromedario"], 
	#["macaco"],["macaca"],
	#[gorila-macho],[gorila-femea],
	#["urso"],["ursa"],
	#["cisne-macho"],["cisne-femea"], 
	#["periquita"],["periquito"], 
	#["rato"],["rata"],
	#["hipopotamo-macho"],["hipopotamo-femea"], 
	#["burro"],["burra"],
	#["jabuti"],["jabota"],
	#["mula"],["mulo"],
	#["jumento"],["jumenta"],
	#["papagaio"],["papagaia"],
	#["tucano-macho"],["tucano-femea"], 
	#["zebra-macho"],["zebra-femea"], 
	#["a-gamba"],["o-gamba"]
]

@onready var grid_container: GridContainer = %GridContainer
@onready var label: Label = $TextureRect/ColorRect/MarginContainer/HBoxContainer/LevelStar/Label
@onready var time_label: Label = $TextureRect/ColorRect/MarginContainer/HBoxContainer/TimeNode/Time
@onready var name_panel: Panel = $NamePanel
@onready var line_edit: LineEdit = $NamePanel/TextureRect/MarginContainer2/LineEdit
@onready var enter_button: TextureButton = $NamePanel/TextureRect/MarginContainer3/EnterButton
@onready var name_label: Label = $TextureRect/ColorRect/MarginContainer/HBoxContainer/NameNode/NameLabel
@onready var audio_stream_hit: AudioStreamPlayer = $AudioStreamHit
@onready var audio_stream_error: AudioStreamPlayer = $AudioStreamError
@onready var audio_stream_error_2: AudioStreamPlayer = $AudioStreamError2

var pause_end_scene = preload("res://scenes/end_pause_scene.tscn")
var board_pairs = []
var card_images_names = []
var flipped_cards = []
var pairs_found = 0
var number_pairs: int
var time_for_label = 0.0
var pending_pairs = []
var pause_instance = null
var tip = false
var cards = []

# data
var date_f
var time_f

var duration = 0 
var miss = 0.0
var hit = 0.0
var consecutive_hits = 0
var consecutive_misses = 0
var long_time = 0  # vezes em que demorou pra jogar

var several_clicks = 0
var hit_percentage = 0.0
var hit_average_time = 0.0
var time_to_start = 0.0

var card_1e2_average = null
var card_1e2_max = null
var card_1e2_min = null

var most_frequent_card = "Nenhuma"
var highest_count_card = -1
var most_frequent_pair = []
var highest_count_pair = -1

var tips_used = 0

var left_click = 0
var right_click = 0
var bottom_click = 0
var top_click = 0
var q1_top_left_click = 0
var q2_top_right_click = 0
var q3_bottom_left_click = 0
var q4_bottom_right_click = 0
var finished_lvl = false

var flag_hit = false
var flag_miss = false
var click_count = 0
var click_threshold = 3
var click_count_card = 0
var awaiting_second_click = false
var first_click_time = 0.0
var card_1e2_times: Array = []
var animal_misses: Array = []

# timers
var timer_start = Timer.new()
var wait_time_start = 2.0
var timer_start_started = false
var timer_clicks = Timer.new()
var wait_time_clicks = 0.29
var timer_hit = Timer.new()
var wait_time_hit = 1.0
var timer_hit_running = false
var elapsed_time_hit = 0.0
var time_hit_sum = 0.0
var timer_tip = Timer.new()
var wait_tip = 5.0
var timer_tip_running = false


func _ready() -> void:
	label.text = str(Global.lvl)
	
	if Save.saved.timer:
		time_label.visible = true
		time_label.text = "00:00"
	else:
		time_label.visible = false
	
	if Global.current_name == "undefined":
		name_label.visible = false
		name_panel.visible = true
		while Global.current_name == "" or Global.current_name == "undefined":
			await enter_button.pressed
		name_panel.visible = false
		name_label.visible = true
		name_label.text = Global.current_name
	else:
		name_label.visible = true
		name_panel.visible = false
	
	create_board() 
	
	# timer start
	add_child(timer_start)  
	timer_start.one_shot = true
	timer_start.start()
	# timer cliques
	add_child(timer_clicks)
	timer_clicks.wait_time = wait_time_clicks
	timer_clicks.one_shot = true
	timer_clicks.connect("timeout", Callable(self, "_on_clicks_timeout"))
	# timer até acerto
	add_child(timer_hit)
	timer_hit.connect("timeout", Callable(self, "_on_hit_timeout"))
	start_timer_hit()
	# timer dica
	add_child(timer_tip)
	timer_tip.wait_time = wait_tip
	timer_tip.connect("timeout", Callable(self, "_on_tip_timeout"))
	
	var date = Time.get_date_dict_from_system()
	date_f = "%02d/%02d/%04d" % [date.day, date.month, date.year]
	
	var time = Time.get_time_dict_from_system()
	time_f = "%02dh %02dmin %02ds" % [time.hour, time.minute, time.second]


func _process(delta: float) -> void:
	if not pairs_found == number_pairs and not get_tree().paused:
		duration += delta
		var minutes = int(duration / 60)
		var seconds = int(duration) % 60
		if Save.saved.timer:
			time_label.visible = true
			time_label.text = "%02d:%02d" % [minutes, seconds]
		else:
			time_label.visible = false
	name_label.text = Global.current_name


func create_board():
	if Global.lvl == 1:
		number_pairs = 6
		grid_container.columns = 6
	elif Global.lvl == 2:
		number_pairs = 12
		grid_container.columns = 8
	elif Global.lvl == 3:
		number_pairs = 20
		grid_container.columns = 10
	
	board_pairs = CARD_IMAGES.duplicate() 
	randomize()
	board_pairs.shuffle()
	if board_pairs.size() > number_pairs:
		board_pairs = board_pairs.slice(0, number_pairs)
	
	for img in board_pairs:
		card_images_names.append(img[0])
		card_images_names.append(img[1])
	randomize()
	card_images_names.shuffle()
	
	var index = 0
	for i in range(number_pairs*2):
		var card_instance = CARD_SCENE.instantiate() 
		card_instance.main = self 
		
		if Global.lvl == 1:  # ajusta tamanho das cartas
			card_instance.h = 250
			card_instance.w = 180
		elif Global.lvl == 2:
			card_instance.h = 185
			card_instance.w = 130
		elif Global.lvl == 3:
			card_instance.h = 145
			card_instance.w = 110
		
		grid_container.add_child(card_instance)
		card_instance.card_image = load("res://assets/animals/" + card_images_names[index] + ".png")
		
		var path = "res://assets/animals/" + card_images_names[index]
		var archive_name = path.get_file().get_basename() 
		
		card_instance.lab = archive_name.replace("1","").replace("2","")
		
		cards.append(card_instance)
		
		index += 1


var pair = null
func add_flipped_card(card):
	if card not in flipped_cards:
		flipped_cards.append(card)
		click_count_card += 1
	if flipped_cards.size() >= 2:
		check_match()
	
	if %Glow.visible:
		if pair == card:
			tips_used += 1
		if flipped_cards.size() != 0:
			if flipped_cards[flipped_cards.size()-1] == card:
				await get_tree().create_timer(1).timeout
			else:
				await get_tree().create_timer(0.5).timeout
		%Glow.visible = false
	
	if Save.saved.tips and (flipped_cards.size() == 1 || flipped_cards.size() == 3):
		timer_tip_running = true
		timer_tip.start()
	
	if tip and Save.saved.tips: 
		if flipped_cards.size() != 0 and animal_misses.size() != 0:
			tip = false
			if flipped_cards.size() == 1 || flipped_cards.size() == 3:
				var n = flipped_cards[flipped_cards.size()-1].card_image.resource_path.get_file().get_basename()
				if n in animal_misses[animal_misses.size()-1]:
					pair = find_pair(flipped_cards[flipped_cards.size() - 1])
					
					var grid = %GridContainer
					var children = grid.get_children()
					
					if Global.lvl == 1:  # ajusta tamanho e posição da dica
						%Glow.size = children[1].size + Vector2(93,87)
						%Glow.global_position = pair.global_position - Vector2(46,45)
					elif Global.lvl == 2:
						%Glow.size = children[1].size + Vector2(74,68)
						%Glow.global_position = pair.global_position - Vector2(36,35)
					elif Global.lvl == 3:
						%Glow.size = children[1].size + Vector2(65,54)
						%Glow.global_position = pair.global_position - Vector2(32,26)
					
					%Glow.visible = true


func find_pair(card):
	var name_card = card.card_image.resource_path.get_file().get_basename()
	var n = find_number(name_card)
	var p = null
	
	for c in CARD_IMAGES:
		if n in c: 
			if c[0] == name_card:
				p = c[1]
			else:
				p = c[0]
	
	p = find_card(p)
	
	return p


func find_card(p): # p = pair, n = name
	for c in cards:
		var n = c.card_image.resource_path.get_file().get_basename()
		if p == n:
			return c
	return null


func find_number(n):
	for c in CARD_IMAGES:
		if n in c:  
			return c[2] 
	return -1


func check_match(): 
	var name_card_1 = flipped_cards[0].card_image.resource_path.get_file().get_basename()
	var name_card_2 = flipped_cards[1].card_image.resource_path.get_file().get_basename()
	var n1 = find_number(name_card_1)
	var n2 = find_number(name_card_2)
	
	if n1 > 0 and n2 > 0:
		if n1 == n2:
			#print("Par encontrado!")
			if Save.saved.sfx:
				randomize()
				var B = 80 
				var r = randi() % 100
				if r < B:
					audio_stream_hit.stream = load("res://assets/sound_effects/hit.mp3")
					audio_stream_hit.volume_db = 20
					audio_stream_hit.play()
			
			flipped_cards[0].found = true
			flipped_cards[1].found = true
			pairs_found += 1
			hit += 1
			stop_timer_hit()
			#print("Tempo até acerto: ", elapsed_time_hit)
			time_hit_sum += elapsed_time_hit
			if flag_hit:
				consecutive_hits += 1
				flag_hit = false
			else:
				flag_hit = true
			check_victory()
		else:
			#print("Não são iguais!")
			miss += 1
			if flag_miss:
				consecutive_misses += 1
				flag_miss = false
			else:
				flag_miss = true
			
			name_card_1 = name_card_1.replace("1","(f)").replace("2","(m)")
			name_card_2 = name_card_2.replace("1","(f)").replace("2","(m)")
			
			var count = 0
			for p in animal_misses:
				if p == [name_card_1, name_card_2] || p == [name_card_2, name_card_1]:
					count += 1
					if Save.saved.warning_error:
						show_error_message(0.7)
					if Save.saved.sfx:
						audio_stream_error.stream = load("res://assets/sound_effects/error.mp3")
						audio_stream_error.volume_db = 18
						audio_stream_error.play()
					if count >= 1:
						tip = true
			
			animal_misses.append([name_card_1, name_card_2])
			
			if flipped_cards.size() >= 2:
				schedule_pair_close(flipped_cards[0], flipped_cards[1])
		
		if flipped_cards.size() >= 2:
			flipped_cards.remove_at(0)
			flipped_cards.remove_at(0)


func schedule_pair_close(card1, card2):
	var timer = get_tree().create_timer(0.8)
	timer.connect("timeout", Callable(self, "_on_pair_timeout").bind(card1, card2))
	pending_pairs.append([card1, card2])


func _on_pair_timeout(card1, card2):
	if not card1.found:
		card1.flip_card()
	if not card2.found:
		card2.flip_card()


func check_victory():
	if pairs_found == number_pairs:
		await get_tree().create_timer(1).timeout
		add_child(pause_end_scene.instantiate())
		finish()
	else:
		start_timer_hit()


func click_card_register():
	var now = Time.get_ticks_msec() / 1000.0
	if awaiting_second_click:
		var interval = now - first_click_time
		card_1e2_times.append(interval)
		awaiting_second_click = false
	else:
		first_click_time = now
		awaiting_second_click = true


func calc_card_1e2():
	if card_1e2_times.is_empty():
		print("Nenhum tempo registrado.")
		return
	
	var sum = 0.0
	card_1e2_min = card_1e2_times[0]
	card_1e2_max = card_1e2_times[0]
	
	for t in card_1e2_times:
		sum += t
		card_1e2_min = min(card_1e2_min, t)
		card_1e2_max = max(card_1e2_max, t)
	
	card_1e2_average = sum / card_1e2_times.size()
	
	card_1e2_average = format_time(card_1e2_average)
	card_1e2_min = format_time(card_1e2_min)
	card_1e2_max = format_time(card_1e2_max)


func format_time(t):
	var mi = int(t) / 60
	var s = int(t) % 60
	var ms = int((t - int(t)) * 1000)
	return "%dmin %ds %dms" % [mi, s, ms]


# alterna o estado de pausa
func _toggle_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		grid_container.visible = false
		get_tree().paused = true
		pause_instance = pause_end_scene.instantiate()
		pause_instance.pause = true
		add_child(pause_instance)
	else:
		if pause_instance:
			grid_container.visible = true
			remove_child(pause_instance)
			pause_instance.queue_free()
			pause_instance = null


func _on_pause_button_pressed():
	_toggle_pause()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if get_tree().paused:
			_toggle_pause()
		else:
			ScreenTransition.transition()
			await ScreenTransition.transitioned_halfway
			get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")


func _on_enter_button_pressed() -> void:
	var name_text = line_edit.text.strip_edges()
	if name_text != "":
		Global.current_name = name_text
		name_panel.visible = false
	else:
		line_edit.placeholder_text = "Nome inválido"
		await enter_button.pressed


func _on_back_name_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/start_menu_scene.tscn")


func start_timer_hit():
	timer_hit.wait_time = 0.1  # intervalo de tempo para checagem (0.1s)
	timer_hit.start()
	timer_hit_running = true
func stop_timer_hit():
	timer_hit.stop()
	timer_hit_running = false
func _on_hit_timeout():
	if timer_hit_running:
		elapsed_time_hit += timer_hit.wait_time

func _on_clicks_timeout():
	click_count = 0  # reseta qdo o tempo expira (cliques demais)


func _on_tip_timeout():
	if flipped_cards.size() == 0: return
	pair = find_pair(flipped_cards[flipped_cards.size() - 1])
	
	var grid = %GridContainer
	var children = grid.get_children()
	
	if Global.lvl == 1:  # ajusta tamanho e posição da dica
		%Glow.size = children[1].size + Vector2(93,87)
		%Glow.global_position = pair.global_position - Vector2(46,45)
	elif Global.lvl == 2:
		%Glow.size = children[1].size + Vector2(74,68)
		%Glow.global_position = pair.global_position - Vector2(36,35)
	elif Global.lvl == 3:
		%Glow.size = children[1].size + Vector2(65,54)
		%Glow.global_position = pair.global_position - Vector2(32,26)
	
	%Glow.visible = true
	
	timer_tip_running = false


func animal_misses_compare():
	var animal_count = {}
	for p in animal_misses:
		for animal in p:
			animal_count[animal] = animal_count.get(animal, 0) + 1
	for animal in animal_count.keys():
		if animal_count[animal] > highest_count_card:
			highest_count_card = animal_count[animal]
			most_frequent_card = animal
	
	var pairs_count = {}
	for p in animal_misses:
		if p.size() == 2:
			var sorted = p.duplicate()
			sorted.sort()
			var key = str(sorted)
			pairs_count[key] = pairs_count.get(key, 0) + 1
			if pairs_count[key] > highest_count_pair:
				highest_count_pair = pairs_count[key]
				most_frequent_pair = sorted


func hit_average_time_f():
	var average
	if (hit != 0):
		average = time_hit_sum/hit
		var minutes = int(average / 60)
		var seconds = int(average) % 60
		var milliseconds = int((average - int(average)) * 100)
		average = "%dmin %ds %03dms" % [minutes, seconds, milliseconds]
	else: average = 'Nenhum acerto'
	return average


func finish():
	var hours = int(duration / 3600)
	var minutes = int(duration / 60) % 60
	var seconds = int(duration) % 60
	var milliseconds = int((duration - int(duration)) * 100)
	duration = "%dh %dmin %ds %03dms" % [hours, minutes, seconds, milliseconds]
	#print("Duration: ", duration)
	
	hit_percentage = miss / (click_count_card/2) * 100.0
	if typeof(hit_percentage) == TYPE_NIL or hit_percentage != hit_percentage:
		hit_percentage = "Nula"
	else:
		hit_percentage = "%.2f%%" % [hit_percentage]
	
	hit_average_time = hit_average_time_f()
	
	minutes = int(time_to_start / 60)
	seconds = int(time_to_start) % 60
	milliseconds = int((time_to_start - int(time_to_start)) * 100)
	time_to_start = "%dmin %ds %03dms" % [minutes, seconds, milliseconds]
	
	calc_card_1e2()
	animal_misses_compare()
	
	write_global()


func _input(event):
	if Global.current_name != "undefined":
		if(event is InputEventMouseButton and event.pressed):
			click_count += 1
			timer_clicks.start()
			if click_count >= click_threshold:
				several_clicks += 1
				if Save.saved.sfx:
					audio_stream_error_2.stream = load("res://assets/sound_effects/error_2.mp3")
					audio_stream_error_2.volume_db = 2
					audio_stream_error_2.play()
				if Save.saved.warning_clicks:
					show_error_message(1.3)
				
				print("Muitos cliques em um curto intervalo de tempo!")
				click_count = 0 
			
			var mouse_position = event.position
			var screen_size = get_viewport().size
			
			var center_x = screen_size.x / 2
			var center_y = screen_size.y / 2
			
			if mouse_position.x < center_x:
				left_click += 1
				if mouse_position.y < center_y:
					q1_top_left_click += 1
					top_click += 1
					#print("Clique: quadrante superior esquerdo")
				else:
					q3_bottom_left_click += 1
					bottom_click += 1
					#print("Clique: quadrante inferior esquerdo")
			else:
				right_click += 1
				if mouse_position.y < center_y:
					q2_top_right_click += 1
					top_click += 1
					#print("Clique: quadrante superior direito")
				else:
					q4_bottom_right_click =+ 1
					bottom_click += 1
					#print("Clique: quadrante inferior direito")
			
		# timer até o primeiro clique
		if event is InputEventMouseButton and event.pressed and not timer_start_started:
			timer_start.stop()
			var end_time = Time.get_ticks_msec()
			time_to_start = (end_time - duration) / 1000.0 
			#print("Tempo até o primeiro clique: ", time_to_start)
			timer_start_started = true
	else:
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				enter_button.emit_signal("pressed")
		elif event is InputEventMouseButton and event.pressed:
			var mouse_pos = get_viewport().get_mouse_position()
			var in_button = $NamePanel/BackNameButton.get_global_rect().has_point(mouse_pos)
			var in_colorrect = $NamePanel.get_global_rect().has_point(mouse_pos)
			var in_textrect = $NamePanel/TextureRect.get_global_rect().has_point(mouse_pos)
			if in_colorrect and not in_textrect and not in_button:
				call_deferred("_on_back_name_button_pressed")


func show_error_message(time):
	$ErrorPanel.visible = true
	await get_tree().create_timer(time).timeout
	$ErrorPanel.visible = false


func write_global():
	Global.date_f = date_f
	Global.time_f = time_f
	Global.finished_lvl = "Sim" if finished_lvl else "Não"
	Global.duration = duration
	Global.miss = str(miss)
	Global.hit = str(hit)
	Global.consecutive_hits = str(consecutive_hits)
	Global.consecutive_misses = str(consecutive_misses)
	if long_time == 1:
		Global.long_time = str(long_time) + " vez"
	else:
		Global.long_time = str(long_time) + " vezes"
	if several_clicks == 1:
		Global.several_clicks = str(several_clicks) + " vez"
	else:
		Global.several_clicks = str(several_clicks) + " vezes"
	Global.hit_percentage = hit_percentage
	Global.hit_average_time = hit_average_time
	Global.time_to_start = time_to_start
	
	if card_1e2_average == null:
		Global.card_1e2_average = "Nulo" 
	else:
		Global.card_1e2_average = str(card_1e2_average)
	if card_1e2_max == null:
		Global.card_1e2_max = "Nulo" 
	else:
		Global.card_1e2_max = str(card_1e2_max)
	if card_1e2_min == null:
		Global.card_1e2_min = "Nulo" 
	else: 
		Global.card_1e2_min = str(card_1e2_min)
	
	Global.most_frequent_card = most_frequent_card
	Global.highest_count_card = "Nulo" if highest_count_card == -1 else str(highest_count_card)
	Global.most_frequent_pair = "Nenhum" if most_frequent_pair == [] else '"[%s,%s]"' % [str(most_frequent_pair[0]), str(most_frequent_pair[1])]
	Global.highest_count_pair = "Nulo" if highest_count_pair == -1 else str(highest_count_pair)
	
	Global.tips_used = str(tips_used)
	
	Global.left_click = left_click
	Global.right_click = right_click
	Global.bottom_click = bottom_click
	Global.top_click = top_click
	Global.q1_top_left_click = q1_top_left_click
	Global.q2_top_right_click = q2_top_right_click
	Global.q3_bottom_left_click = q3_bottom_left_click
	Global.q4_bottom_right_click = q4_bottom_right_click
	exportar_para_csv()


func exportar_para_csv():
	#var file_path = "user://dados.csv"  
	
	var dir = DirAccess.open("/")
	var target_dir = "/storage/emulated/0/Documents/Jogo Da Memória"
	if dir.make_dir_recursive(target_dir) == OK:
		print("Pasta criada em: " + target_dir)
	else:
		print("Houve um erro ao criar a pasta ou ela já existe: " + target_dir)
	
	var file_path = "/storage/emulated/0/Documents/Jogo Da Memória/dados.csv"
	
	var data = [Global.current_name, date_f, time_f, Global.finished_lvl, Global.lvl, duration, miss, 
			hit, consecutive_hits, consecutive_misses, Global.long_time, Global.several_clicks, hit_percentage,
			time_to_start, hit_average_time, Global.card_1e2_average, Global.card_1e2_max, Global.card_1e2_min,
			most_frequent_card, Global.highest_count_card, Global.most_frequent_pair, Global.highest_count_pair,
			Global.tips_used, left_click, right_click, bottom_click, top_click, q1_top_left_click, 
			q2_top_right_click, q3_bottom_left_click, q4_bottom_right_click]
	
	var file_exists = FileAccess.file_exists(file_path)
	var write_headers = true

	if file_exists:
		var check_file = FileAccess.open(file_path, FileAccess.READ)
		if check_file:
			if check_file.get_length() > 0:
				var first_line = check_file.get_line()
				if first_line.begins_with("Nome"):
					write_headers = false
			check_file.close()

	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()

		if write_headers:
			var headers = [
				"Nome", "Data", "Hora", "Finalizado", "Nível", "Duração", "Erros", "Acertos", "Acertos Consecutivos",
				"Erros Consecutivos", "Demorou para jogar", "Cliques demais", "Porcentagem de Acertos",
				"Tempo para começar", "Média entre acertos", "Média entre duas cartas",
				"Máx. duas cartas", "Mín. duas cartas",
				"Carta mais errada", "C. mais errada (vezes)", "Par mais errado", "Par mais errado (vezes)",
				"Dicas usadas", "Cliques lado esquerdo", "Cliques lado direito", "Cliques Inferiores", 
				"Cliques Superiores", "Quadrante 1", "Quadrante 2", "Quadrante 3", "Quadrante 4"
			]
			file.store_line(",".join(headers))

		var line = []
		for v in data:
			line.append(str(v))
		file.store_line(",".join(line))
		file.close()
		print("Arquivo atualizado com sucesso: ", file_path)
	else:
		print("Erro ao acessar o arquivo")
