extends Node
class_name OSCCursorController

const ADDR_PATTERN_ROOT := "/lc/cursor/"
const ADDR_MOVE := ADDR_PATTERN_ROOT + "move"
const ADDR_MOVE_DELTA := ADDR_PATTERN_ROOT + "moveDelta"
const ADDR_PRESS := ADDR_PATTERN_ROOT + "press"
const ADDR_RELEASE := ADDR_PATTERN_ROOT + "release"
const ADDR_ATTEMPT_TOGGLE_GRAB := ADDR_PATTERN_ROOT + "attemptToggleGrab"

const TIME_KEEP_ALIVE_MS := 2000

@onready var _osc: OSCManager = $"../OSCManager"
@onready var _cursor_manager: CursorManager = $"../CursorManager"

var _last_cursor_updates: Dictionary = {}
var _last_cursor_positions: Dictionary = {}

func _ready():
	if not Config.osc_enable_cursor_controller:
		print("Removed OSCCursorController")
		queue_free()
		return
	
	_osc.set_osc_cursor_controller(self)

func _process(delta):
	if _cursor_manager == null: return
	
	var time = Time.get_ticks_msec()
	for cursor_id in _last_cursor_updates.keys():
		if _last_cursor_updates[cursor_id] + TIME_KEEP_ALIVE_MS < time:
			_last_cursor_updates.erase(cursor_id)
			_last_cursor_positions[cursor_id] = _cursor_manager.get_cursor(cursor_id).position
			_cursor_manager.despawn(cursor_id)

func on_osc_msg_received(addr: String, args: Array):
	if _cursor_manager == null: return
		
	var cursor_id: String = "osc_" + args[0]
	
	_assure_alive(cursor_id)
	
	match addr:
		ADDR_MOVE:
			if _osc.check_osc_args(addr, args, "sff"):
				_cursor_manager.move(cursor_id, Vector2(args[1], args[2]))
		ADDR_MOVE_DELTA:
			if _osc.check_osc_args(addr, args, "sff"):
				_cursor_manager.move_delta(cursor_id, Vector2(args[1], args[2]))
		ADDR_PRESS:
			if _osc.check_osc_args(addr, args, "s"):
				_cursor_manager.press(cursor_id)
		ADDR_RELEASE:
			if _osc.check_osc_args(addr, args, "s"):
				_cursor_manager.release(cursor_id)
		ADDR_ATTEMPT_TOGGLE_GRAB:
			if _osc.check_osc_args(addr, args, "s"):
				_cursor_manager.attempt_toggle_grab(cursor_id)
			
func _assure_alive(cursor_id: String):
	if not cursor_id in _last_cursor_updates:
		var start_position: Vector2
		if not cursor_id in _last_cursor_positions:
			start_position = Vector2(100, 100)
		else:
			start_position = _last_cursor_positions[cursor_id]

		_cursor_manager.spawn(cursor_id, start_position, Config.osc_display_cursor_hint)
	
	_last_cursor_updates[cursor_id] = Time.get_ticks_msec()
