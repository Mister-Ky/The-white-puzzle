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

@export var grid_offset := Vector2i.ZERO :
	set(value):
		grid_offset = value
		if not is_node_ready():
			await ready
		queue_redraw()

@onready var sprite : Sprite2D = %sprite

const cell_size := Vector2(64, 64)

func _ready() -> void:
	size = size

func _draw() -> void:
	if Engine.is_editor_hint() or debug:
		var grid_end_x := grid_offset.x * size.x + size.x * cell_size.x
		var grid_end_y := grid_offset.y * size.y + size.y * cell_size.y
		
		for i in range(size.x + 1):
			var x_position := grid_offset.x * size.x + i * cell_size.x
			draw_line(Vector2(x_position, grid_offset.y * size.y), Vector2(x_position, grid_end_y), Color.WHITE)
		
		for i in range(size.y + 1):
			var y_position := grid_offset.y * size.y + i * cell_size.y
			draw_line(Vector2(grid_offset.x * size.x, y_position), Vector2(grid_end_x, y_position), Color.WHITE)
