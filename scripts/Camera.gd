class_name Camera
extends Camera2D

@export var zoom_factor := 1.1
@export var speed := 10.0

func _ready() -> void:
	pass

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("middle_up"):
		zoom *= zoom_factor
	elif event.is_action_pressed("middle_down"):
		zoom /= zoom_factor
	zoom = clamp(zoom, Vector2(0.05, 0.05), Vector2(3.0, 3.0))

func _physics_process(_delta : float) -> void:
	var dir_x := Input.get_axis("ui_left", "ui_right")
	var dir_y := Input.get_axis("ui_up", "ui_down")
	global_position += Vector2(dir_x, dir_y) * speed
