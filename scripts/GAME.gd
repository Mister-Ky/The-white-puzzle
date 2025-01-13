class_name GAME
extends Node

@onready var ui : CanvasLayer = %ui
@onready var info : Label = %info
@onready var right_mode : TextureButton = %right_mode
@onready var victory : Control = %victory
@onready var zoom : VBoxContainer = %zoom
@onready var timer : TimeLabel = %timer

@onready var board : Board = %board
@onready var camera : Camera = %camera
@onready var puzzles : Node2D = %puzzles
@onready var puzzles_storage : Control = %puzzles_storage
@onready var rotation : AudioStreamPlayer = %rotation

@onready var z_puzzles : Array[Puzzle] = []
var blocked := 0
var first_text_info : String
var num_puzzles : int
var currently_dragged_puzzle : Puzzle = null
var right_android_mode := false
var move : Node # джостик
var move_mouse_inside := false

func set_sides() -> void:
	var offset := randi() % 2
	for y in board.size.y:
		for x in board.size.x:
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
	for y in board.size.y:
		for x in board.size.x:
			var puzzle := z_puzzles[y * board.size.x + x]
			
			if y > 0:
				var offset := randi() % 2
				puzzle.top_side = Puzzle.Side.Tab - offset
				z_puzzles[(y - 1) * board.size.x + x].bottom_side = Puzzle.Side.Slot + offset
			if y < board.size.y - 1:
				var offset := randi() % 2
				puzzle.bottom_side = Puzzle.Side.Tab - offset
				z_puzzles[(y + 1) * board.size.x + x].top_side = Puzzle.Side.Slot + offset
			if x > 0:
				var offset := randi() % 2
				puzzle.left_side = Puzzle.Side.Tab - offset
				z_puzzles[y * board.size.x + (x - 1)].right_side = Puzzle.Side.Slot + offset
			if x < board.size.x - 1:
				var offset := randi() % 2
				puzzle.right_side = Puzzle.Side.Tab - offset
				z_puzzles[y * board.size.x + (x + 1)].left_side = Puzzle.Side.Slot + offset

func _ready() -> void:
	if Main.is_android():
		android_right_update()
		set_process(false)
		info.hide()
		info.queue_free()
		move = load("res://addons/virtual_joystick/virtual_joystick_scene.tscn").instantiate()
		move.name = "move"
		ui.add_child(move)
		ui.move_child(move, zoom.get_index())
		move.base.mouse_entered.connect(func() -> void: move_mouse_inside = true)
		move.base.mouse_exited.connect(func() -> void: move_mouse_inside = false)
	else:
		first_text_info = info.text
		var del_paths : Array = ["ui/right_mode", "ui/zoom"]
		for dp in del_paths:
			var dn = get_node(dp)
			dn.hide()
			dn.queue_free()
	victory.hide()
	camera.global_position = board.global_position + board.sprite.get_rect().size * Vector2(board.size) / 2
	num_puzzles = board.size.x * board.size.y
	for i in num_puzzles:
		var puzzle := Puzzle.new()
		puzzle.name = str(i)
		puzzles_storage.add_child(puzzle)
		if Main.is_android():
			puzzle.scale *= 2
		puzzle.position = Vector2(randi() % int(puzzles_storage.size.x - puzzle.texture.get_size().x * puzzle.scale.x), randi() % int(puzzles_storage.size.y - puzzle.texture.get_size().y * puzzle.scale.y)) + puzzle.texture.get_size() * puzzle.scale / 2
		puzzle.rotation_degrees = [0, 90, 180, 270].pick_random()
		z_puzzles.append(puzzle)
	if Main.hard:
		set_sides_hard()
	else:
		set_sides()
	for p : Puzzle in z_puzzles:
		p.create()
	z_puzzles.sort_custom(sort_puzzles)

func sort_puzzles(a : Puzzle, b : Puzzle) -> bool:
	if not a.z_index == b.z_index:
		return a.z_index > b.z_index
	return a.get_index() > b.get_index()

func sort_pos_puzzles(a : Puzzle, b : Puzzle) -> bool:
	if a.global_position.y == b.global_position.y:
		return a.global_position.x < b.global_position.x
	return a.global_position.y < b.global_position.y

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
		blocked += 1
		puzzle.block = true
		puzzle.set_z(-1)
		z_puzzles.sort_custom(sort_puzzles)

func _physics_process(_delta : float) -> void:
	var left_click_pressed := Input.is_action_just_pressed("left_click")
	var left_click_released := Input.is_action_just_released("left_click")
	var right_click_pressed := Input.is_action_just_pressed("right_click")
	var right_click_released := Input.is_action_just_released("right_click")
	
	if Main.is_android():
		if right_android_mode:
			right_click_pressed = left_click_pressed
			right_click_released = left_click_released
			left_click_pressed = false
			left_click_released = false
		if (left_click_pressed or right_click_pressed) and move_mouse_inside:
			return
	
	for puzzle : Puzzle in z_puzzles:
		if (left_click_pressed or right_click_pressed) and puzzle.get_rect().has_point(puzzle.get_local_mouse_position()) and not currently_dragged_puzzle:
			if not timer.is_running:
				timer.start()
			currently_dragged_puzzle = puzzle
			if (right_click_pressed and not puzzle.block) or left_click_pressed:
				puzzle.set_z(1)
			for p : Puzzle in z_puzzles:
				if not p.block and not p == puzzle:
					p.set_z(0)
			z_puzzles.sort_custom(sort_puzzles)
		elif (left_click_released or right_click_released) and currently_dragged_puzzle == puzzle:
			if left_click_released:
				move_puzzle(currently_dragged_puzzle)
			currently_dragged_puzzle = null
			if check():
				win()
				return
			elif blocked == num_puzzles:
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
			if puzzle.block: blocked -= 1
			puzzle.block = false
			puzzle.show()
			if puzzle.get_parent() == puzzles_storage and puzzles_storage.get_local_mouse_position().x <= 0:
				puzzle.hide()
				puzzles_storage.remove_child(puzzle)
				puzzles.add_child(puzzle)
				if Main.is_android():
					puzzle.scale /= 2
			elif puzzle.get_parent() == puzzles and puzzles_storage.get_local_mouse_position().x > 0:
				puzzle.hide()
				puzzles.remove_child(puzzle)
				puzzles_storage.add_child(puzzle)
				if Main.is_android():
					puzzle.scale *= 2
			break

func rot() -> void:
	currently_dragged_puzzle = null
	if check():
		win()
	else:
		set_physics_process(true)

func check() -> bool:
	if blocked == num_puzzles:
		if num_puzzles == 1: return true
		z_puzzles.sort_custom(sort_pos_puzzles)
		for y in board.size.y:
			for x in board.size.x:
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
	tween.tween_property(%storage, "global_position:x", get_viewport().size.x + %storage.size.x, 1.0)
	tween.tween_callback(next_win)

func next_win() -> void:
	right_mode.disabled = true
	right_mode.hide()
	victory.show()
	$win.play()
	await get_tree().physics_frame # чтобы установилась позиция у timer point
	await get_tree().physics_frame
	var tween := create_tween().set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
	tween.tween_property(timer, "global_position", %victory/vbox/vbox1/point/timer_point.global_position - timer.size / 2, 2.0)

func check_side_match(side_1 : Puzzle.Side, side_2 : Puzzle.Side) -> bool:
	if side_1 == Puzzle.Side.Slot and side_2 == Puzzle.Side.Tab:
		return true
	if side_1 == Puzzle.Side.Tab and side_2 == Puzzle.Side.Slot:
		return true
	return false

func _on_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

# windows
var hold_time := 1.5
var time_held := 0.0
var is_key_held := false
func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if is_key_held:
			time_held += delta
		else:
			time_held = 0.0
			is_key_held = true
		if time_held >= hold_time:
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")
		info.text = "EXIT" + ".".repeat(int(time_held / 0.5) + 1)
	elif Input.is_action_just_released("ui_cancel"):
		time_held = 0.0
		is_key_held = false
		info.text = first_text_info

# android
func _on_android_right_pressed() -> void:
	right_android_mode = not right_android_mode
	android_right_update()
func android_right_update() -> void:
	right_mode.texture_normal = preload("res://data/rotation_on.png") if right_android_mode else preload("res://data/rotation_off.png")
