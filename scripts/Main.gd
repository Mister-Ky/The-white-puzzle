extends Node

## Разделитель для консоли. Используйте так - [code]print(Main.CONLINE)[/code].
const CONLINE := "----------------------------------------" # 40

func _ready() -> void:
	pass

func set_fullscreen(value : bool) -> void:
	if value:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		exit()
	elif event.is_action_pressed("toggle_fullscreen"):
		set_fullscreen(not get_window().mode == Window.MODE_FULLSCREEN)

func exit(exit_code : int = 0) -> void:
	print(CONLINE)
	print("EXIT " + str(exit_code))
	get_tree().quit(exit_code)
