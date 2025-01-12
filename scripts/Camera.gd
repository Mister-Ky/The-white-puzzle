class_name Camera
extends Camera2D

@export var zoom_factor := 1.1
@export var speed := 10.0

func _ready() -> void:
	if Main.is_android():
		set_process_input(false)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("middle_up"):
		zoom *= zoom_factor
	elif event.is_action_pressed("middle_down"):
		zoom /= zoom_factor
	zoom = clamp(zoom, Vector2.ONE * 0.05, Vector2.ONE * 3)

func _physics_process(_delta : float) -> void:
	var extra_speed := 1.0
	if Input.is_action_pressed("shift"):
		extra_speed = 2.5
	global_position += Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")) * speed * extra_speed

# android
func _on_zoom_value_changed(value : float) -> void:
	zoom = Vector2.ONE * value
