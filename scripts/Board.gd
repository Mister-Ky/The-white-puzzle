class_name Board
extends Node2D

@onready var sprite : Sprite2D = %sprite

var grid_offset := Vector2i(5, 5)
var cell_centers : Array[Vector2] = []

var size : Vector2i :
	set(_value): pass
	get: return Main.size

var cell_size : Vector2i :
	set(_value): pass
	get: return Main.cell_size

func _calculate_cell_centers() -> void:
	cell_centers.clear()
	for i in range(size.x):
		for j in range(size.y):
			var x_position := grid_offset.x * size.x + i * cell_size.x + cell_size.x / 2
			var y_position := grid_offset.y * size.y + j * cell_size.y + cell_size.y / 2
			cell_centers.append(Vector2(x_position, y_position))

func _ready() -> void:
	sprite.scale = Main.size
	_calculate_cell_centers()

func _draw() -> void:
	if Main.debug:
		var grid_end_x := grid_offset.x * size.x + size.x * cell_size.x
		var grid_end_y := grid_offset.y * size.y + size.y * cell_size.y
		
		for i in range(size.x + 1):
			var x_position := grid_offset.x * size.x + i * cell_size.x
			draw_line(Vector2(x_position, grid_offset.y * size.y), Vector2(x_position, grid_end_y), Color.WHITE)
		
		for i in range(size.y + 1):
			var y_position := grid_offset.y * size.y + i * cell_size.y
			draw_line(Vector2(grid_offset.x * size.x, y_position), Vector2(grid_end_x, y_position), Color.WHITE)
		
		for center : Vector2 in cell_centers:
			draw_circle(center, 3, Color.RED)
