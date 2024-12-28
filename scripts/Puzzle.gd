class_name Puzzle
extends Sprite2D

var cell := Vector2i.ZERO

var block := false

func _ready() -> void:
	texture = load("res://data/puzzle.png")
	scale = Main.cell_size / Vector2i(texture.get_size())
