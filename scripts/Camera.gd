class_name Camera
extends Camera2D

@onready var target_zoom : Vector2 = zoom
@export var zoom_factor := 1.1
@export var zoom_speed := 10.0
@export var speed := 600.0
@export var acceleration := 15.0

var current_velocity := Vector2.ZERO

func _ready() -> void:
	if Main.is_android():
		set_process_input(false)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("middle_up"):
		target_zoom *= zoom_factor
	elif event.is_action_pressed("middle_down"):
		target_zoom /= zoom_factor
	target_zoom = clamp(target_zoom, Vector2.ONE * 0.05, Vector2.ONE * 3)

func _process(delta : float) -> void:
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
	
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	var extra_speed := 1.0
	if Input.is_action_pressed("shift"):
		extra_speed = 2.5
	
	var target_velocity := direction * speed * extra_speed
	current_velocity = current_velocity.lerp(target_velocity, acceleration * delta)
	global_position += current_velocity * delta

# android
func _on_zoom_value_changed(value : float) -> void:
	target_zoom = Vector2.ONE * value
