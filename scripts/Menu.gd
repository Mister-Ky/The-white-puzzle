class_name Menu
extends Node

@onready var X : HSlider = %X
@onready var Y : HSlider = %Y
@onready var grid : CheckBox = %grid
@onready var hard : CheckBox = %hard
@onready var master : HSlider = %master
@onready var music : HSlider = %music
@onready var sfx : HSlider = %sfx
@onready var addons_android : Label = %addons_android

@onready var X_label : Label = %X_label
@onready var Y_label : Label = %Y_label

var size_max := 128

func _ready() -> void:
	if Main.is_android():
		size_max /= 2
	else:
		addons_android.hide()
	X.max_value = size_max
	Y.max_value = size_max
	update()
	grid.button_pressed = Main.grid
	hard.button_pressed = Main.hard
	master.value = Main.master
	_on_master_value_changed(master.value)
	music.value = Main.music
	_on_music_value_changed(music.value)
	sfx.value = Main.sfx
	_on_sfx_value_changed(sfx.value)

func update() -> void:
	X.value = Main.size.x
	Y.value = Main.size.y

func _on_play_pressed() -> void:
	Main.size = Vector2i(X.value, Y.value)
	get_tree().change_scene_to_file("res://scenes/GAME.tscn")

func _on_x_value_changed(value : float) -> void:
	X_label.text = "Width : " + str(value)

func _on_y_value_changed(value : float) -> void:
	Y_label.text = "Height : " + str(value)

func _on_reset_pressed() -> void:
	Main.size = Vector2i(10, 10)
	update()

func _on_exit_pressed() -> void:
	Main.exit(0)

func _on_grid_toggled(toggled_on : bool) -> void:
	Main.grid = toggled_on

func _on_hard_toggled(toggled_on : bool) -> void:
	Main.hard = toggled_on

func _on_master_value_changed(value : float) -> void:
	Main.master = value
	Main.setBusVolumeDB(Main.master)

func _on_music_value_changed(value : float) -> void:
	Main.music = value
	Main.setBusVolumeDB(Main.music, "music")

func _on_sfx_value_changed(value : float) -> void:
	Main.sfx = value
	Main.setBusVolumeDB(Main.sfx, "sfx")

func _on_godot_icon_pressed() -> void:
	OS.shell_open("https://godotengine.org/")


func _on_x_minus_pressed() -> void:
	X.value -= 1
func _on_x_plus_pressed() -> void:
	X.value += 1
func _on_y_minus_pressed() -> void:
	Y.value -= 1
func _on_y_plus_pressed() -> void:
	Y.value += 1
