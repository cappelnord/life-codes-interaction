extends Node
class_name CursorManager

var _cursor_node = preload("res://interaction/nodes/cursor_node.tscn")

var cursor_image_base = preload("res://interaction/graphics/cursors/cursor_base.png")
var cursor_image_attempt_grab = preload("res://interaction/graphics/cursors/cursor_attempt_grab.png")
var cursor_image_hover = preload("res://interaction/graphics/cursors/cursor_hover.png")
var cursor_image_grab = preload("res://interaction/graphics/cursors/cursor_grab.png")

var cursors = {}

var _users_inactive = false
var _time_of_last_cursor_activity := 0


@onready var _osc: OSCManager = $"../OSCManager"
@onready var _block_manager: CodeBlockManager = $"../CodeBlockManager"

func spawn(id: String, position: Vector2)->Cursor:
	# TODO: make sure that we don't duplicate a cursor
	var cursor = _cursor_node.instantiate() as Cursor
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

func device_orientation(id: String, absolute: Variant, alpha: float, beta: float, gamma: float):
	print([id, absolute, alpha, beta, gamma])
	if cursors.has(id):
		var cursor := cursors[id] as Cursor
		var x := cursor.position.x
		var y := remap(beta, 0, 90, Config.app_render_height, 0)
		cursor.move(Vector2(x, y))
		


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
	
	if cursors.size() > 0:
		_time_of_last_cursor_activity = now
		if _users_inactive:
			_users_became_active()
	
	if not _users_inactive:
		if (_time_of_last_cursor_activity + inactivity_time) < now:
			_users_became_inactive()
	
	if Config.debug_test_interaction_integrity and OS.is_debug_build():
		_test_interaction_integrity()

func _users_became_active():
	_users_inactive = false
	print("Users became active")
	_osc.send_users_active()

func _users_became_inactive():
	_users_inactive = true
	print("Users became inactive")
	_osc.send_users_inactive()

func _test_interaction_integrity():
	for key in cursors:
		var cursor := cursors[key] as Cursor
		
		# _grab_block and _hover_block can be different
		assert(cursor._grab_block == null or cursor._grab_block == cursor._hover_block)
		
		if cursor._hover_block:
			assert(cursor._hover_block._active_cursor == cursor)
		
		if cursor._grab_block:
			assert(cursor._grab_block._active_cursor == cursor)
	
	for key in _block_manager._slots:
		var slot := _block_manager._slots[key] as CodeBlockSlot
		if slot.block != null:
			var block := slot.block
			if block._active_cursor:
				assert(block._active_cursor._hover_block == block or block._active_cursor._grab_block == block)

			
	
