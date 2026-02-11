class_name TimeLabel
extends Label

var elapsed_time := 0.0
var is_running := false

func _ready() -> void:
	_set_time_text(elapsed_time)
	set_process(is_running)

func _set_time_text(time : float) -> void:
	text = "Time: " + String("%0.2f" % time) + " sec"

func start() -> void:
	is_running = true
	set_process(is_running)

func stop() -> void:
	is_running = false
	set_process(is_running)

func reset() -> void:
	elapsed_time = 0.0

func _process(delta : float) -> void:
	elapsed_time += delta
	_set_time_text(elapsed_time)
