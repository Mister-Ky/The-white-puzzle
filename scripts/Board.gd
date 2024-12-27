class_name Board
extends Node2D

@export var size := Vector2i(10, 10) :
	set(value):
		size = value.clampi(1, 1024)
		scale = size

func _ready() -> void:
	size = size
