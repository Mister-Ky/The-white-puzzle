extends Node

## Разделитель для консоли. Используйте так - [code]print(Main.CONLINE)[/code].
const CONLINE := "----------------------------------------" # 40

const cell_size := Vector2i(64, 64)
var puzzle_texture := load("res://data/puzzle.png")
var none := load("res://data/none.png")
var slot := load("res://data/slot.png")
var tab := load("res://data/tab.png")

# Нужен чтобы из меню в игру перевести настройки
var size := Vector2i(10, 10)
# Тоже но с сеткой
var grid := false
# И со сложностью
var hard := true

var master := 1.0
var music := 1.0
var sfx := 1.0

var _android := OS.get_name() == "Android"

func _ready() -> void:
	setBusVolumeDB(0.0)

func is_android() -> bool:
	return _android or true

func set_fullscreen(value : bool) -> void:
	if value:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED

## Настройка аудио колонки.
func setBusVolumeDB(value : float, bus_name : StringName = &"Master") -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(value))

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		set_fullscreen(not get_window().mode == Window.MODE_FULLSCREEN)

func exit(exit_code : int = 0) -> void:
	print(CONLINE)
	print("EXIT " + str(exit_code))
	get_tree().quit(exit_code)
