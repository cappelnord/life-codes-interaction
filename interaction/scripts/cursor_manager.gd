extends Node
class_name CursorManager

var _cursor_node = preload("res://interaction/nodes/cursor_node.tscn")

var cursor_image_base = preload("res://interaction/graphics/cursors/cursor_base.png")
var cursor_image_attempt_grab = preload("res://interaction/graphics/cursors/cursor_attempt_grab.png")
var cursor_image_hover = preload("res://interaction/graphics/cursors/cursor_hover.png")
var cursor_image_grab = preload("res://interaction/graphics/cursors/cursor_grab.png")

var cursors = {}

func spawn(id: String, position: Vector2)->Cursor:
	# TODO: make sure that we don't duplicate a cursor
	var cursor = _cursor_node.instantiate()
	cursor.move(position)
	cursor.id = id
	cursors[id] = cursor
	add_child(cursor)
	return cursor

func despawn(id: String):
	if cursors.has(id):
		cursors[id].cleanup()
		cursors[id].queue_free()
		cursors.erase(id)

func move(id: String, new_position: Vector2):
	if cursors.has(id):
		cursors[id].move(new_position)	

func move_delta(id: String, delta: Vector2):
	if cursors.has(id):
		cursors[id].move_delta(delta)
	
	# TODO: notify anyone who might be interested that a cursor has moved

func user_connected(id: String):
	if cursors.has(id):
		cursors[id].user_connected()

func user_disconnected(id: String):
	if cursors.has(id):
		cursors[id].user_disconnected()

func press(id: String):
	if cursors.has(id):
		cursors[id].press()

func release(id: String):
	if cursors.has(id):
		cursors[id].release()

func attempt_toggle_grab(id: String):
	if cursors.has(id):
		cursors[id].attempt_toggle_grab()

func get_cursor(id: String) -> Cursor:
	if cursors.has(id):
		return cursors[id]
	else:
		return null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
