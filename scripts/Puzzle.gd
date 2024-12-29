class_name Puzzle
extends Sprite2D

var cell := Vector2i.ZERO

var block := false

func _ready() -> void:
	texture = load("res://data/puzzle.png")
	scale = Main.cell_size / Vector2i(texture.get_size())
	material = load("res://data/puzzle_material.tres")

func _draw() -> void:
	if Main.debug:
		draw_string(ThemeDB.fallback_font, Vector2.ZERO, str(cell))
