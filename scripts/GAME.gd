class_name GAME
extends Node

@onready var puzzles : Node2D = %puzzles

var currently_dragged_puzzle = null
var currently_z_index := 0

func _ready() -> void:
	for i in range(0, 15):
		var puzzle := Puzzle.new()
		puzzle.global_position = Vector2(randi() % 500, randi() % 500)
		puzzles.add_child(puzzle)

func sort_puzzles(a : Puzzle, b : Puzzle) -> bool:
	if not a.z_index == b.z_index:
		return a.z_index > b.z_index
	return a.get_index() > b.get_index()

func _physics_process(_delta : float) -> void:
	var left_click_pressed := Input.is_action_just_pressed("left_click")
	var left_click_released := Input.is_action_just_released("left_click")
	var z_puzzles := puzzles.get_children()
	z_puzzles.sort_custom(sort_puzzles)
	for puzzle : Puzzle in z_puzzles:
		if left_click_pressed and puzzle.get_rect().has_point(puzzle.get_local_mouse_position()):
			currently_dragged_puzzle = puzzle
			currently_z_index += 1
			currently_dragged_puzzle.z_index += currently_z_index
		elif left_click_released and currently_dragged_puzzle == puzzle:
			currently_dragged_puzzle.z_index = currently_z_index
			currently_dragged_puzzle = null
		if currently_dragged_puzzle == puzzle:
			puzzle.global_position = puzzle.get_global_mouse_position()
			break
