class_name GAME
extends Node

@onready var board : Board = %board
@onready var puzzles : Node2D = %puzzles
@onready var puzzles_storage : Control = %puzzles_storage
@onready var camera : Camera = %camera

var num_puzzles : int :
	set(_value): pass
	get: return board.size.x * board.size.y

var currently_dragged_puzzle = null
var currently_z_index := 0

@onready var z_puzzles := []

func _ready() -> void:
	for i in range(num_puzzles):
		var puzzle := Puzzle.new()
		puzzles_storage.add_child(puzzle)
		puzzle.position = Vector2(randi() % int(puzzles_storage.size.x - puzzle.texture.get_size().x), randi() % int(puzzles_storage.size.y - puzzle.texture.get_size().y))
		puzzle.position += puzzle.texture.get_size() / 2
		z_puzzles.append(puzzle)
	z_puzzles.sort_custom(sort_puzzles)

func sort_puzzles(a : Puzzle, b : Puzzle) -> bool:
	if not a.z_index == b.z_index:
		return a.z_index > b.z_index
	return a.get_index() > b.get_index()

func _physics_process(_delta : float) -> void:
	var left_click_pressed := Input.is_action_pressed("left_click")
	var left_click_released := Input.is_action_just_released("left_click")
	var right_click_pressed := Input.is_action_just_pressed("right_click")
	var right_click_released := Input.is_action_just_released("right_click")
	
	for puzzle : Puzzle in z_puzzles:
		if (left_click_pressed or right_click_pressed) and puzzle.get_rect().has_point(puzzle.get_local_mouse_position()) and not currently_dragged_puzzle:
			currently_dragged_puzzle = puzzle
			currently_z_index += 1
			puzzle.z_index = currently_z_index
			z_puzzles.sort_custom(sort_puzzles)
		elif (left_click_released or right_click_released) and currently_dragged_puzzle == puzzle:
			currently_dragged_puzzle = null
		if right_click_pressed and currently_dragged_puzzle == puzzle:
			puzzle.rotate(1.5708)
		if left_click_pressed and currently_dragged_puzzle == puzzle:
			puzzle.global_position = puzzle.get_global_mouse_position()
			puzzle.show()
			if puzzle.get_parent() == puzzles_storage and puzzles_storage.get_local_mouse_position().x <= 0:
				puzzle.hide()
				puzzles_storage.remove_child(puzzle)
				puzzles.add_child(puzzle)
			elif puzzle.get_parent() == puzzles and puzzles_storage.get_local_mouse_position().x > 0:
				puzzle.hide()
				puzzles.remove_child(puzzle)
				puzzles_storage.add_child(puzzle)
			break
