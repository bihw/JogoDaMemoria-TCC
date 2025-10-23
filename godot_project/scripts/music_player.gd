extends AudioStreamPlayer

@onready var timer: Timer = $Timer

var tween


func _ready():
	if Save.saved.music:
		play()
	finished.connect(on_finished)
	timer.connect("timeout", Callable(self, "on_timer_timeout"))


func turn_up_down(value):
	var idx = AudioServer.get_bus_index("Background")
	var current = AudioServer.get_bus_volume_db(idx)
	
	tween.tween_method(
		func(v): AudioServer.set_bus_volume_db(idx, v),
		current,
		value,
		1
	)


func on_finished():
	timer.start()


func on_timer_timeout():
	play()
