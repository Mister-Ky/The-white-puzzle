@tool
class_name Board
extends Node2D

@export var debug := false

@export var size := Vector2i(10, 10) :
	set(value):
		size = value.clampi(1, 256)
		if not is_node_ready():
			await ready
		sprite.scale = size
		queue_redraw()
		_calculate_cell_centers()

@export var grid_offset := Vector2i(5, 5) :
	set(value):
		grid_offset = value
		if not is_node_ready():
			await ready
		queue_redraw()
		_calculate_cell_centers()

@onready var sprite : Sprite2D = %sprite

var cell_centers : Array[Vector2] = []

func _calculate_cell_centers() -> void:
	cell_centers.clear()
	for i in range(size.x):
		for j in range(size.y):
			var x_position := grid_offset.x * size.x + i * Main.cell_size.x + Main.cell_size.x / 2
			var y_position := grid_offset.y * size.y + j * Main.cell_size.y + Main.cell_size.y / 2
			cell_centers.append(Vector2(x_position, y_position))

func _ready() -> void:
	size = size
	grid_offset = grid_offset

func _draw() -> void:
	if Engine.is_editor_hint() or debug:
		var grid_end_x := grid_offset.x * size.x + size.x * Main.cell_size.x
		var grid_end_y := grid_offset.y * size.y + size.y * Main.cell_size.y
		
		for i in range(size.x + 1):
			var x_position := grid_offset.x * size.x + i * Main.cell_size.x
			draw_line(Vector2(x_position, grid_offset.y * size.y), Vector2(x_position, grid_end_y), Color.WHITE)
		
		for i in range(size.y + 1):
			var y_position := grid_offset.y * size.y + i * Main.cell_size.y
			draw_line(Vector2(grid_offset.x * size.x, y_position), Vector2(grid_end_x, y_position), Color.WHITE)
		
		for center : Vector2 in cell_centers:
			draw_circle(center, 3, Color.RED)
