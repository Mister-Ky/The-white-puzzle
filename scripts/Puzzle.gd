class_name Puzzle
extends Sprite2D

var block := false

func _ready() -> void:
	z_index = 1
	texture = load("res://data/puzzle.png")
	scale = Main.cell_size / Vector2i(texture.get_size())
	material = load("res://data/puzzle_material.tres")
