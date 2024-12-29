class_name Menu
extends Node

@onready var X : HSlider = %X
@onready var Y : HSlider = %Y
@onready var debug : CheckBox = %debug

@onready var X_label : Label = %X_label
@onready var Y_label : Label = %Y_label

func _ready() -> void:
	update()

func update() -> void:
	X.value = Main.size.x
	Y.value = Main.size.y
	debug.button_pressed = Main.debug

func _on_play_pressed() -> void:
	Main.size = Vector2i(X.value, Y.value)
	get_tree().change_scene_to_file("res://scenes/GAME.tscn")

func _on_x_value_changed(value : float) -> void:
	X_label.text = "X : " + str(value)

func _on_y_value_changed(value : float) -> void:
	Y_label.text = "Y : " + str(value)

func _on_reset_pressed() -> void:
	Main.size = Vector2i(10, 10)
	update()

func _on_debug_toggled(toggled_on : bool) -> void:
	Main.debug = toggled_on
