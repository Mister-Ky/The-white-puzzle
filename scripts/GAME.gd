class_name GAME
extends Node

@onready var board : Board = %board
@onready var puzzles : Node2D = %puzzles
@onready var puzzles_storage : Control = %puzzles_storage

var num_puzzles : int :
	set(_value): pass
	get: return board.size.x * board.size.y

var currently_dragged_puzzle = null
var currently_z_index := 0

func _ready() -> void:
	for i in range(0, num_puzzles):
		var puzzle := Puzzle.new()
		puzzle.global_position = Vector2(randi() % 100, randi() % 100)
		puzzles_storage.add_child(puzzle)

func sort_puzzles(a : Puzzle, b : Puzzle) -> bool:
	if not a.z_index == b.z_index:
		return a.z_index > b.z_index
	return a.get_index() > b.get_index()

func _physics_process(_delta : float) -> void:
	var left_click_pressed := Input.is_action_just_pressed("left_click")
	var left_click_released := Input.is_action_just_released("left_click")
	var right_click_pressed := Input.is_action_just_pressed("right_click")
	var right_click_released := Input.is_action_just_released("right_click")
	
	var z_puzzles := puzzles_storage.get_children()
	z_puzzles.append_array(puzzles.get_children())
	z_puzzles.sort_custom(sort_puzzles)
	
	for puzzle : Puzzle in z_puzzles:
		if (left_click_pressed or right_click_pressed) and puzzle.get_rect().has_point(puzzle.get_local_mouse_position()) and not currently_dragged_puzzle:
			currently_dragged_puzzle = puzzle
			currently_z_index += 1
			puzzle.z_index = currently_z_index
		elif (left_click_released or right_click_released) and currently_dragged_puzzle == puzzle:
			currently_dragged_puzzle = null
		if right_click_pressed and currently_dragged_puzzle == puzzle:
			puzzle.rotate(deg_to_rad(90))
		if Input.is_action_pressed("left_click") and currently_dragged_puzzle == puzzle:
			puzzle.global_position = puzzle.get_global_mouse_position()
			if puzzle.get_parent() == puzzles_storage and puzzle.get_rect().position.x + puzzle.get_rect().size.x <= puzzles_storage.get_rect().position.x:
				puzzles_storage.remove_child(puzzle)
				puzzles.add_child(puzzle)
			break
