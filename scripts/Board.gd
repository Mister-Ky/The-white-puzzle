class_name Board
extends Node2D

@onready var sprite : Sprite2D = %sprite

var cell_centers : Array[Vector2] = []

var size : Vector2i :
	set(_value): pass
	get: return Main.size

var cell_size : Vector2i :
	set(_value): pass
	get: return Main.cell_size

func _calculate_cell_centers() -> void:
	cell_centers.clear()
	for i in size.x:
		for j in size.y:
			var x_position := i * cell_size.x + cell_size.x / 2
			var y_position := j * cell_size.y + cell_size.y / 2
			cell_centers.append(Vector2(x_position, y_position))

func _ready() -> void:
	sprite.scale = size
	_calculate_cell_centers()

func _draw() -> void:
	if Main.grid:
		var grid_end_x := size.x * cell_size.x
		var grid_end_y := size.y * cell_size.y
		
		for i in size.x + 1:
			var x_position := i * cell_size.x
			draw_line(Vector2(x_position, 0), Vector2(x_position, grid_end_y), Color.WHITE)
		
		for i in size.y + 1:
			var y_position := i * cell_size.y
			draw_line(Vector2(0, y_position), Vector2(grid_end_x, y_position), Color.WHITE)
