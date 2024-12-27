class_name Puzzle
extends Sprite2D

var cell := Vector2i.ZERO

func _ready() -> void:
	texture = load("res://data/puzzle.png")
