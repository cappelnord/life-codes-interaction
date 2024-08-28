extends Node
class_name CursorManager

class CursorStyleSet:
	var base
	var attempt_grab
	var hover
	var grab
	
	func _init(base, attempt_grab, hover, grab):
		self.base = base
		self.attempt_grab = grab
		self.hover = hover
		self.grab = grab

var _cursor_node = preload("res://interaction/nodes/cursor_node.tscn")

var cursors = {}
var _cursor_styles = {}

var _users_inactive = false
var _users_inactive_long = false
var _time_of_last_cursor_activity := 0


@onready var _osc: OSCManager = $"../OSCManager"
@onready var _block_manager: CodeBlockManager = $"../CodeBlockManager"
@onready var _hints_manager: CodeBlockHintsManager = $"../CodeBlockManager/CodeBlockHintsManager"

func spawn(id: String, position: Vector2, style: StringName=Cursor.default_cursor_style)->Cursor:
	# TODO: make sure that we don't duplicate a cursor
	var cursor = _cursor_node.instantiate() as Cursor
	cursor.move(position)
	cursor.id = id
	cursor.style = style
	cursors[id] = cursor
	add_child(cursor)
	_hints_manager.cursor_hint(cursor)
	_osc.send_cursor_spawned(cursor.id)
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
	
	# &a
	_cursor_styles[Cursor.default_cursor_style] = CursorStyleSet.new(
		preload("res://interaction/graphics/cursors/cursor_base_a.png"),
		preload("res://interaction/graphics/cursors/cursor_attempt_grab_a.png"),
		preload("res://interaction/graphics/cursors/cursor_hover_a.png"),
		preload("res://interaction/graphics/cursors/cursor_grab_a.png")
	)
	
	_cursor_styles[&"b"] = CursorStyleSet.new(
		preload("res://interaction/graphics/cursors/cursor_base_b.png"),
		preload("res://interaction/graphics/cursors/cursor_attempt_grab_b.png"),
		preload("res://interaction/graphics/cursors/cursor_hover_b.png"),
		preload("res://interaction/graphics/cursors/cursor_grab_b.png")
	)
	
	_cursor_styles[&"c"] = CursorStyleSet.new(
		preload("res://interaction/graphics/cursors/cursor_base_c.png"),
		preload("res://interaction/graphics/cursors/cursor_attempt_grab_c.png"),
		preload("res://interaction/graphics/cursors/cursor_hover_c.png"),
		preload("res://interaction/graphics/cursors/cursor_grab_c.png")
	)
	
	_cursor_styles[&"d"] = CursorStyleSet.new(
		preload("res://interaction/graphics/cursors/cursor_base_d.png"),
		preload("res://interaction/graphics/cursors/cursor_attempt_grab_d.png"),
		preload("res://interaction/graphics/cursors/cursor_hover_d.png"),
		preload("res://interaction/graphics/cursors/cursor_grab_d.png")
	)

func cursor_style(id: StringName)->Variant:
	if _cursor_styles.has(id):
		return _cursor_styles[id]
	else:
		return _cursor_styles[Cursor.default_cursor_style]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var now := Time.get_ticks_msec()
	var inactivity_time = Config.app_inactivity_time * 1000
	var long_inactivity_time = Config.app_long_inactivity_time * 1000
	
	if cursors.size() > 0:
		_time_of_last_cursor_activity = now
		if _users_inactive:
			_users_became_active()
	
	if not _users_inactive:
		if (_time_of_last_cursor_activity + inactivity_time) < now:
			_users_became_inactive()
	
	if not _users_inactive_long:
		if (_time_of_last_cursor_activity + long_inactivity_time) < now:
			_users_became_inactive_long()
	
	if Config.debug_test_interaction_integrity and OS.is_debug_build():
		_test_interaction_integrity()

func _users_became_active():
	_users_inactive = false
	_users_inactive_long = false
	print("Users became active")
	_osc.send_users_active()

func _users_became_inactive():
	_users_inactive = true
	print("Users became inactive")
	_osc.send_users_inactive()

func _users_became_inactive_long():
	_users_inactive_long = true;
	print("Users became long inactive")
	_osc.send_users_inactive_long()

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

			
	
