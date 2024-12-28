class_name GAME
extends Node

@onready var board : Board = %board
@onready var camera : Camera = %camera
@onready var puzzles : Node2D = %puzzles
@onready var puzzles_storage : Control = %puzzles_storage

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

func is_cell_occupied(cell_position : Vector2) -> bool:
	for puzzle : Puzzle in z_puzzles:
		if puzzle.get_rect().has_point(cell_position - puzzle.global_position) and puzzle.block:
			return true
	return false

func move_puzzle(puzzle: Puzzle) -> void:
	var nearest_point: Vector2 = board.cell_centers[0] + board.global_position
	var min_distance := puzzle.global_position.distance_to(nearest_point)
	
	for center: Vector2 in board.cell_centers:
		center += board.global_position
		var distance := puzzle.global_position.distance_to(center)
		if distance < min_distance:
			nearest_point = center
			min_distance = distance
	
	if (puzzle.get_rect().has_point(nearest_point - puzzle.global_position)) and (not is_cell_occupied(nearest_point)):
		puzzle.global_position = nearest_point
		puzzle.block = true
		puzzle.z_index = 0
		z_puzzles.sort_custom(sort_puzzles)

func _physics_process(_delta : float) -> void:
	var left_click_pressed := Input.is_action_pressed("left_click")
	var left_click_released := Input.is_action_just_released("left_click")
	var right_click_pressed := Input.is_action_just_pressed("right_click")
	var right_click_released := Input.is_action_just_released("right_click")
	
	var blocked := 0
	for puzzle : Puzzle in z_puzzles:
		if puzzle.block: blocked += 1
		if (left_click_pressed or right_click_pressed) and puzzle.get_rect().has_point(puzzle.get_local_mouse_position()) and not currently_dragged_puzzle:
			currently_dragged_puzzle = puzzle
			currently_z_index += 1
			puzzle.z_index = currently_z_index
			z_puzzles.sort_custom(sort_puzzles)
		elif (left_click_released or right_click_released) and currently_dragged_puzzle == puzzle:
			if left_click_released:
				move_puzzle(currently_dragged_puzzle)
			currently_dragged_puzzle = null
		if right_click_pressed and currently_dragged_puzzle == puzzle:
			puzzle.rotate(1.5708)
		if left_click_pressed and currently_dragged_puzzle == puzzle:
			puzzle.global_position = puzzle.get_global_mouse_position()
			puzzle.block = false
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
	if blocked == num_puzzles:
		pass
