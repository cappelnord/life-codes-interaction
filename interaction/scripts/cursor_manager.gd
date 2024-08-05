extends Node
class_name CursorManager

var _cursor_node = preload("res://interaction/nodes/cursor_node.tscn")

var cursor_image_base = preload("res://interaction/graphics/cursors/cursor_base.png")
var cursor_image_attempt_grab = preload("res://interaction/graphics/cursors/cursor_attempt_grab.png")
var cursor_image_hover = preload("res://interaction/graphics/cursors/cursor_hover.png")
var cursor_image_grab = preload("res://interaction/graphics/cursors/cursor_grab.png")

var cursors = {}

var _users_inactive = false
var _time_of_last_movement := 0
var _cursor_has_moved = true

@onready var _osc: OSCManager = $"../OSCManager"

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
		_cursor_has_moved = true

func move_delta(id: String, delta: Vector2):
	if cursors.has(id):
		cursors[id].move_delta(delta)
		_cursor_has_moved = true
	
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

func device_orientation(id: String, absolute: Variant, alpha: float, beta: float, gamma: float):
	print([id, absolute, alpha, beta, gamma])


func get_cursor(id: String) -> Cursor:
	if cursors.has(id):
		return cursors[id]
	else:
		return null

# Called when the node enters the scene tree for the first time.
func _ready():
	_osc.send_users_active()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var now := Time.get_ticks_msec()
	var inactivity_time = Config.app_inactivity_time * 1000
	
	if _cursor_has_moved:
		_time_of_last_movement = now
		_cursor_has_moved = false
		if _users_inactive:
			_users_became_active()
	
	if not _users_inactive:
		if (_time_of_last_movement + inactivity_time) < now:
			_users_became_inactive()

func _users_became_active():
	_users_inactive = false
	print("Users became active")
	_osc.send_users_active()

func _users_became_inactive():
	_users_inactive = true
	print("Users became inactive")
	_osc.send_users_inactive()
