extends Node

## Разделитель для консоли. Используйте так - [code]print(Main.CONLINE)[/code].
const CONLINE := "----------------------------------------" # 40

const cell_size := Vector2i(64, 64)

# Нужен чтобы из меню в игру перевести настройки
var size := Vector2i(10, 10)
# Тоже но с дебагом
var debug := false

func _ready() -> void:
	pass

func set_fullscreen(value : bool) -> void:
	if value:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_node_or_null("/root/Menu"):
			exit()
		elif get_node_or_null("/root/GAME"):
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	elif event.is_action_pressed("toggle_fullscreen"):
		set_fullscreen(not get_window().mode == Window.MODE_FULLSCREEN)

func exit(exit_code : int = 0) -> void:
	print(CONLINE)
	print("EXIT " + str(exit_code))
	get_tree().quit(exit_code)
