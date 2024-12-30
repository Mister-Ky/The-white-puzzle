class_name GAME
extends Node

@onready var board : Board = %board
@onready var camera : Camera = %camera
@onready var puzzles : Node2D = %puzzles
@onready var puzzles_storage : Control = %puzzles_storage
@onready var storage : Panel = %storage
@onready var victory : Control = %victory

var num_puzzles : int

var currently_dragged_puzzle : Puzzle = null

@onready var z_puzzles : Array[Puzzle] = []

func set_sides():
	for y in range(board.size.y):
		for x in range(board.size.x):
			var puzzle := z_puzzles[y * board.size.x + x]
			
			if y > 0:
				puzzle.top_side = Puzzle.Side.Tab
				z_puzzles[(y - 1) * board.size.x + x].bottom_side = Puzzle.Side.Slot
			if y < board.size.y - 1:
				puzzle.bottom_side = Puzzle.Side.Tab
				z_puzzles[(y + 1) * board.size.x + x].top_side = Puzzle.Side.Slot
			if x > 0:
				puzzle.left_side = Puzzle.Side.Tab
				z_puzzles[y * board.size.x + (x - 1)].right_side = Puzzle.Side.Slot
			if x < board.size.x - 1:
				puzzle.right_side = Puzzle.Side.Tab
				z_puzzles[y * board.size.x + (x + 1)].left_side = Puzzle.Side.Slot
	
	for p : Puzzle in z_puzzles:
		p.create()
		p.set_z(1)

func _ready() -> void:
	victory.hide()
	num_puzzles = board.size.x * board.size.y
	for i in range(num_puzzles):
		var puzzle := Puzzle.new()
		puzzle.name = str(i)
		puzzles_storage.add_child(puzzle)
		puzzle.position = Vector2(randi() % int(puzzles_storage.size.x - puzzle.texture.get_size().x), randi() % int(puzzles_storage.size.y - puzzle.texture.get_size().y)) + puzzle.texture.get_size() / 2
		z_puzzles.append(puzzle)
	set_sides()
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

func move_puzzle(puzzle : Puzzle) -> void:
	var nearest_point : Vector2 = board.cell_centers[0] + board.global_position
	var min_distance := puzzle.global_position.distance_to(nearest_point)
	
	for center : Vector2 in board.cell_centers:
		center += board.global_position
		var distance := puzzle.global_position.distance_to(center)
		if distance < min_distance:
			nearest_point = center
			min_distance = distance
	
	if (puzzle.get_rect().has_point(nearest_point - puzzle.global_position)) and (not is_cell_occupied(nearest_point)):
		puzzle.global_position = nearest_point
		puzzle.block = true
		puzzle.set_z(0)
		z_puzzles.sort_custom(sort_puzzles)

func _physics_process(_delta : float) -> void:
	var left_click_pressed := Input.is_action_pressed("left_click")
	var left_click_released := Input.is_action_just_released("left_click")
	var right_click_pressed := Input.is_action_just_pressed("right_click")
	var right_click_released := Input.is_action_just_released("right_click")
	
	for puzzle : Puzzle in z_puzzles:
		if (left_click_pressed or right_click_pressed) and puzzle.get_rect().has_point(puzzle.get_local_mouse_position()) and not currently_dragged_puzzle:
			currently_dragged_puzzle = puzzle
			if not puzzle.block:
				puzzle.set_z(2)
			for p : Puzzle in z_puzzles:
				if not p.block and not p == puzzle:
					p.set_z(1)
			z_puzzles.sort_custom(sort_puzzles)
		elif (left_click_released or right_click_released) and currently_dragged_puzzle == puzzle:
			if left_click_released:
				move_puzzle(currently_dragged_puzzle)
			currently_dragged_puzzle = null
			if check():
				win()
				return
		if right_click_pressed and currently_dragged_puzzle == puzzle:
			set_physics_process(false)
			var tween := create_tween().set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
			tween.tween_property(puzzle, "rotation_degrees", puzzle.rotation_degrees + 90, 0.2)
			tween.tween_callback(rot)
			return
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

func rot() -> void:
	currently_dragged_puzzle = null
	if check():
		win()
	else:
		set_physics_process(true)

func check() -> bool:
	var blocked := 0
	for p : Puzzle in z_puzzles:
		if p.block: blocked += 1
	if blocked == num_puzzles:
		return true
	return false

func win() -> void:
	set_physics_process(false)
	var tween := create_tween().set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
	tween.tween_property(storage, "global_position:x", get_viewport().size.x + storage.size.x, 1.0)
	tween.tween_callback(victory.show)

func _on_again_pressed() -> void:
	get_tree().reload_current_scene()
