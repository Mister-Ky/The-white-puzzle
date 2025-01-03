class_name GAME
extends Node

@onready var board : Board = %board
@onready var camera : Camera = %camera
@onready var puzzles : Node2D = %puzzles
@onready var puzzles_storage : Control = %puzzles_storage
@onready var storage : Panel = %storage
@onready var victory : Control = %victory
@onready var timer : TimeLabel = %timer

@onready var rotation : AudioStreamPlayer = %rotation

var num_puzzles : int

var currently_dragged_puzzle : Puzzle = null

@onready var z_puzzles : Array[Puzzle] = []

func set_sides() -> void:
	var offset := randi() % 2
	for y in range(board.size.y):
		for x in range(board.size.x):
			var puzzle := z_puzzles[y * board.size.x + x]
			
			if y > 0:
				puzzle.top_side = Puzzle.Side.Slot + offset
				z_puzzles[(y - 1) * board.size.x + x].bottom_side = Puzzle.Side.Tab - offset
			if y < board.size.y - 1:
				puzzle.bottom_side = Puzzle.Side.Slot + offset
				z_puzzles[(y + 1) * board.size.x + x].top_side = Puzzle.Side.Tab - offset
			if x > 0:
				puzzle.left_side = Puzzle.Side.Tab - offset
				z_puzzles[y * board.size.x + (x - 1)].right_side = Puzzle.Side.Slot + offset
			if x < board.size.x - 1:
				puzzle.right_side = Puzzle.Side.Tab - offset
				z_puzzles[y * board.size.x + (x + 1)].left_side = Puzzle.Side.Slot + offset

func set_sides_hard() -> void:
	for y in range(board.size.y):
		for x in range(board.size.x):
			var puzzle := z_puzzles[y * board.size.x + x]
			
			if y > 0:
				if randi() % 2 == 0:
					puzzle.top_side = Puzzle.Side.Tab
					z_puzzles[(y - 1) * board.size.x + x].bottom_side = Puzzle.Side.Slot
				else:
					puzzle.top_side = Puzzle.Side.Slot
					z_puzzles[(y - 1) * board.size.x + x].bottom_side = Puzzle.Side.Tab
			if y < board.size.y - 1:
				if randi() % 2 == 0:
					puzzle.bottom_side = Puzzle.Side.Tab
					z_puzzles[(y + 1) * board.size.x + x].top_side = Puzzle.Side.Slot
				else:
					puzzle.bottom_side = Puzzle.Side.Slot
					z_puzzles[(y + 1) * board.size.x + x].top_side = Puzzle.Side.Tab
			if x > 0:
				if randi() % 2 == 0:
					puzzle.left_side = Puzzle.Side.Tab
					z_puzzles[y * board.size.x + (x - 1)].right_side = Puzzle.Side.Slot
				else:
					puzzle.left_side = Puzzle.Side.Slot
					z_puzzles[y * board.size.x + (x - 1)].right_side = Puzzle.Side.Tab
			if x < board.size.x - 1:
				if randi() % 2 == 0:
					puzzle.right_side = Puzzle.Side.Tab
					z_puzzles[y * board.size.x + (x + 1)].left_side = Puzzle.Side.Slot
				else:
					puzzle.right_side = Puzzle.Side.Slot
					z_puzzles[y * board.size.x + (x + 1)].left_side = Puzzle.Side.Tab

func _ready() -> void:
	victory.hide()
	camera.global_position = board.global_position + board.get_node("sprite").get_rect().size * Vector2(board.size) / 2
	num_puzzles = board.size.x * board.size.y
	for i in range(num_puzzles):
		var puzzle := Puzzle.new()
		puzzle.name = str(i)
		puzzles_storage.add_child(puzzle)
		puzzle.position = Vector2(randi() % int(puzzles_storage.size.x - puzzle.texture.get_size().x), randi() % int(puzzles_storage.size.y - puzzle.texture.get_size().y)) + puzzle.texture.get_size() / 2
		var rotations := [0, 90, 180, 270]
		puzzle.rotation_degrees = rotations[randi() % rotations.size()]
		z_puzzles.append(puzzle)
	if Main.hard:
		set_sides_hard()
	else:
		set_sides()
	for p : Puzzle in z_puzzles:
		p.create()
		p.set_z(1)
	z_puzzles.sort_custom(sort_puzzles)

func sort_puzzles(a : Puzzle, b : Puzzle) -> bool:
	if not a.z_index == b.z_index:
		return a.z_index > b.z_index
	return a.get_index() > b.get_index()

func sort_pos_puzzles(a : Puzzle, b : Puzzle) -> bool:
	if a.global_position.y < b.global_position.y:
		return true
	elif a.global_position.y == b.global_position.y:
		if a.global_position.x < b.global_position.x:
			return true
	return false

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
	var left_click_pressed := Input.is_action_just_pressed("left_click")
	var left_click_released := Input.is_action_just_released("left_click")
	var right_click_pressed := Input.is_action_just_pressed("right_click")
	var right_click_released := Input.is_action_just_released("right_click")
	
	for puzzle : Puzzle in z_puzzles:
		if (left_click_pressed or right_click_pressed) and puzzle.get_rect().has_point(puzzle.get_local_mouse_position()) and not currently_dragged_puzzle:
			if not timer.is_running:
				timer.start()
			currently_dragged_puzzle = puzzle
			if (right_click_pressed and not puzzle.block) or left_click_pressed:
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
			else:
				z_puzzles.sort_custom(sort_puzzles)
		if right_click_pressed and currently_dragged_puzzle == puzzle:
			set_physics_process(false)
			rotation.play()
			var tween := create_tween().set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
			tween.tween_property(puzzle, "rotation_degrees", puzzle.rotation_degrees + 90, 0.2)
			tween.tween_callback(rot)
			return
		if Input.is_action_pressed("left_click") and currently_dragged_puzzle == puzzle:
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
		if num_puzzles == 1: return true
		z_puzzles.sort_custom(sort_pos_puzzles)
		for y in range(board.size.y):
			for x in range(board.size.x):
				var puzzle := z_puzzles[y * board.size.x + x]
				
				if y > 0:
					if not check_side_match(puzzle.get_rotated_sides()["top"], z_puzzles[(y - 1) * board.size.x + x].get_rotated_sides()["bottom"]):
						return false
				if y < board.size.y - 1:
					if not check_side_match(puzzle.get_rotated_sides()["bottom"], z_puzzles[(y + 1) * board.size.x + x].get_rotated_sides()["top"]):
						return false
				if x > 0:
					if not check_side_match(puzzle.get_rotated_sides()["left"], z_puzzles[y * board.size.x + (x - 1)].get_rotated_sides()["right"]):
						return false
				if x < board.size.x - 1:
					if not check_side_match(puzzle.get_rotated_sides()["right"], z_puzzles[y * board.size.x + (x + 1)].get_rotated_sides()["left"]):
						return false
		return true
	return false

func win() -> void:
	set_physics_process(false)
	timer.stop()
	var tween := create_tween().set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
	tween.tween_property(storage, "global_position:x", get_viewport().size.x + storage.size.x, 1.0)
	tween.tween_callback(pok_win)

func pok_win() -> void:
	victory.show()
	$win.play()
	await get_tree().physics_frame
	await get_tree().physics_frame
	var tween := create_tween().set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
	tween.tween_property(timer, "global_position", %victory/vbox/vbox1/point/timer_point.global_position - timer.size / 2, 2.0)

func check_side_match(side_1 : Puzzle.Side, side_2 : Puzzle.Side) -> bool:
	if side_1 == Puzzle.Side.Slot and side_2 == Puzzle.Side.Tab:
		return true
	if side_1 == Puzzle.Side.Tab and side_2 == Puzzle.Side.Slot:
		return true
	return side_1 == Puzzle.Side.None and side_2 == Puzzle.Side.None

func _on_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")




func set_info(text : String) -> void:
	$ui/info.text = text

func return_info() -> void:
	$ui/info.text = """ESCAPE — hold to exit to menu
	Left click — drag puzzles
	Right click — rotate puzzles
	WASD — camera movement
	Mouse wheel — camera zoom"""

var hold_time := 1.5
var time_held := 0.0
var is_key_held := false
func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if is_key_held:
			time_held += delta
		else:
			is_key_held = true
			time_held = 0.0
		
		set_info("EXIT" + ".".repeat(int(time_held / 0.5) + 1))
		
		if time_held >= hold_time:
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
			is_key_held = false
			time_held = 0.0
	else:
		is_key_held = false
		time_held = 0.0
		return_info()
