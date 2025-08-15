## The snake, composed of several body segments - a new one is added each time
## it eats a piece of food.
extends Node2D

## Prevents the snake changing its direction more than once before it has
## properly advanced one cell. Checked to validate player input.
var _can_change_direction: bool = true

## The direction the snake is moving towards.
var _direction: Vector2i

## The packed scene containing the sprite of a single body segment.
## A new sprite is added as a child node of this scene, whenever a new segment
## is added to the body.
@onready
var _segment_scene: PackedScene = get_meta("segment_scene")

enum Direct {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var going: Direct

## Appends a new body segment, making it the new snake's head.
func add_segment(at_cell: Vector2i) -> void:
	var segment := _instantiate_segment(at_cell)
	add_child(segment)
	move_child(segment, 0)


## Returns the cell where the head of the snake should move next, wrapping
## around the edges of the grid if needed.
func get_next_step(grid_width: int, grid_height: int) -> Vector2i:
	var cell: Vector2i = get_child(0).cell
	var x := wrapi(cell.x + _direction.x, 0, grid_width)
	var y := wrapi(cell.y + _direction.y, 0, grid_height)
	return Vector2i(x, y)

func get_allowed_move(next_x: int, next_y: int, gw: int, gh: int) -> Vector2i:
	var body: Array[Vector2i]= get_occupied_cells()
	var head: Vector2i = body[0]
	var next_pos := Vector2i(next_x, next_y)
	if not next_pos in body:
		return next_pos
	else:
		var x = [wrapi(head.x + 1, 0, gw),wrapi(head.x - 1, 0, gw)]
		var y = [wrapi(head.y + 1, 0, gh),wrapi(head.y - 1, 0, gh)]
		var allowed = []
		for dx in x:
			for dy in y:
				var p = Vector2i(dx, dy)
				if not p in body:
					allowed.append(p)
		if allowed:
			#var rand_i = randi() % allowed.size()
			#return allowed[rand_i]
			allowed.shuffle()
			for pos in allowed:
				if pos.x == head.x or pos.y == head.y:
					return pos
		return next_pos
		
func get_dir(x_dir: int, y_dir: int) -> Vector2i:
	if x_dir == -1: 
		if going == Direct.RIGHT:
			x_dir = 0
		else:
			going = Direct.LEFT
	elif x_dir == 1:
		if going == Direct.LEFT:
			x_dir = 0
		else:
			going = Direct.RIGHT
	if y_dir == -1: 
		if going == Direct.DOWN:
			y_dir = 0
		else:
			going = Direct.UP
	elif y_dir == 1:
		if going == Direct.UP:
			y_dir = 0
		else:
			going = Direct.DOWN 
	return Vector2i(x_dir, y_dir)
	
func get_next_auto_step(grid_width: int, grid_height: int, x_dir: int, y_dir: int) -> Vector2i:
	var cell: Vector2i = get_child(0).cell
	var d: Vector2i = get_dir(x_dir, y_dir)
	var x := wrapi(cell.x + d.x, 0, grid_width)
	var y := wrapi(cell.y + d.y, 0, grid_height)
	return get_allowed_move(x, y, grid_width, grid_height)


## Returns the list of cells occupied by the snake body on the grid.
func get_occupied_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for node in get_children():
		result.append(node.cell)
	return result


## Places the snake on the grid with the desired number of initial segments,
## starting at the given grid cell and facing the given direction.
func initialize(size: int, at_cell: Vector2i, starting_direction: Vector2i) -> void:
	_direction = Vector2i.DOWN #starting_direction
	going = Direct.DOWN
	for _i in size:
		add_child(_instantiate_segment(at_cell))
		at_cell -= _direction


## Sets the direction of the snake 90 degress to the left.
func turn_left() -> void:
	if _can_change_direction:
		#_direction = Vector2i.LEFT #Vector2i(_direction.y, -_direction.x)
		if not going == Direct.RIGHT:
			print("left ", going, " ", Direct.UP, Direct.DOWN)
			_direction = Vector2i.LEFT
			going = Direct.LEFT
		_can_change_direction = false


## Sets the direction of the snake 90 degress to the right.
func turn_right() -> void:
	if _can_change_direction:
		#_direction = Vector2i.RIGHT #Vector2i(-_direction.y, _direction.x)
		if not going == Direct.LEFT:
			print("right ", going, " ", Direct.UP, Direct.DOWN)
			_direction = Vector2i.RIGHT
			going = Direct.RIGHT
		_can_change_direction = false

func turn_up() -> void:
	if _can_change_direction:
		#_direction = Vector2i.UP
		if not going == Direct.DOWN:
			_direction = Vector2i.UP
			going = Direct.UP
		_can_change_direction = false

func turn_down() -> void:
	if _can_change_direction:
		#_direction = Vector2i.DOWN
		if not going == Direct.UP:
			_direction = Vector2i.DOWN
			going = Direct.DOWN
		_can_change_direction = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		turn_up()
	if event.is_action_pressed("ui_down"):
		turn_down()

## Moves the snake to the given grid cell.
func walk(cell: Vector2i) -> void:
	var tail := get_child(-1)
	tail.cell = cell
	move_child(tail, 0)
	_can_change_direction = true


## Checks if the snake will run over its body.
func will_collide(cell: Vector2i) -> bool:
	# Check only from the 4th segment onwards; avoid checking
	# a collision with the tail while chasing it.
	return get_children().slice(3, -1).any(func(n): return n.cell == cell)


## Instantiate a new body segment sprite at the given grid cell.
func _instantiate_segment(at_cell: Vector2i) -> Sprite2D:
	var result := _segment_scene.instantiate()
	result.cell = at_cell
	return result
