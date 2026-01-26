class_name Puzzle
extends Sprite2D

enum Side {
	None,   # Нет соединения
	Slot,   # Паз
	Tab     # Клюв
}

var top_side := Side.None
var bottom_side := Side.None
var left_side := Side.None
var right_side := Side.None

var block := false

var top : Sprite2D
var right : Sprite2D
var bottom : Sprite2D
var left : Sprite2D

func set_z(z : int) -> void:
	z_index = z
	top.z_index = z
	right.z_index = z
	bottom.z_index = z
	left.z_index = z

func _ready() -> void:
	texture = Main.puzzle_texture

func create() -> void:
	top = Sprite2D.new()
	#top.rotation_degrees = 0
	top.texture = get_texture_side(top_side)
	top.position.y = -16
	if top_side == Side.Tab:
		top.position.y *= 2
	
	right = Sprite2D.new()
	right.rotation_degrees = 90
	right.texture = get_texture_side(right_side)
	right.position.x = 16
	if right_side == Side.Tab:
		right.position.x *= 2
	
	bottom = Sprite2D.new()
	bottom.rotation_degrees = 180
	bottom.texture = get_texture_side(bottom_side)
	bottom.position.y = 16
	if bottom_side == Side.Tab:
		bottom.position.y *= 2
	
	left = Sprite2D.new()
	left.rotation_degrees = 270
	left.texture = get_texture_side(left_side)
	left.position.x = -16
	if left_side == Side.Tab:
		left.position.x *= 2
	
	add_child(top)
	add_child(right)
	add_child(bottom)
	add_child(left)

func get_texture_side(side : Puzzle.Side) -> Texture2D:
	match side:
		Side.None:
			return Main.none
		Side.Slot:
			return Main.slot
		Side.Tab:
			return Main.tab
		_:
			return null

func get_rotated_sides() -> Dictionary:
	var sides := {}
	match posmod(roundi(rotation_degrees), 360):
		0:
			sides["top"] = top_side
			sides["right"] = right_side
			sides["bottom"] = bottom_side
			sides["left"] = left_side
		90:
			sides["top"] = left_side
			sides["right"] = top_side
			sides["bottom"] = right_side
			sides["left"] = bottom_side
		180:
			sides["top"] = bottom_side
			sides["right"] = left_side
			sides["bottom"] = top_side
			sides["left"] = right_side
		270:
			sides["top"] = right_side
			sides["right"] = bottom_side
			sides["bottom"] = left_side
			sides["left"] = top_side
		_:
			return sides
	return sides
