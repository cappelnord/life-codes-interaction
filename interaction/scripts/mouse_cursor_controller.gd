extends Node
class_name MouseCursorController

@onready var _manager: CursorManager = $"../CursorManager"

@export var id: String = "mouse"
@export var secondary_id: String = "mouse2"


var _active = false
var _secondary = false
var _last_position : Vector2 =  Vector2(100, 100)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Config.mouse_enable:
		print("Removed MouseCursorController")
		queue_free()
		return

func _unhandled_input(event):
	var this_id = id
	
	if _secondary:
		this_id = secondary_id
		
	if _active:
		if event is InputEventMouseMotion:
			_manager.move_delta(this_id, event.relative * Config.mouse_speed)
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_manager.press(this_id)
				else:
					_manager.release(this_id)
	else:
		if event is InputEventMouseMotion and (not _secondary):
			_last_position = event.position * Config.mouse_viewport_modifier

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_N and _active:
			_toggle_secondary()
		if event.keycode == KEY_M or event.keycode == KEY_ESCAPE and _active:
			if(not _active): _activate()
			else: _deactivate()

func _activate():
	var cursor := _manager.spawn(id, _last_position)
	cursor.user_progress.progress.connect(_on_user_progress)
	cursor.feedback.connect(_on_cursor_feedback)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_active = true

func _secondary_on():
	var cursor := _manager.spawn(secondary_id, _last_position)
	cursor.user_progress.progress.connect(_on_user_progress)
	cursor.feedback.connect(_on_cursor_feedback)
	_secondary = true

func _secondary_off():
	_secondary = false
	_manager.despawn(secondary_id)
	
func _toggle_secondary():
	if _secondary:
		_secondary_off()
	else:
		_secondary_on()

func _deactivate():
	var cursor : Cursor = _manager.get_cursor(id)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if cursor != null:
		_last_position = cursor.position
	_manager.despawn(id)
	
	if _secondary:
		_secondary_off()
	
	_active = false

func _on_user_progress(cursor_id: String, progress: CursorUserProgress.Progress):
	print("User Progress: " + str(CursorUserProgress.Progress.keys()[progress]))

func _on_cursor_feedback(cursor_id: String, feedback: Cursor.Feedback):
	print("Cursor Feedback: " + str(Cursor.Feedback.keys()[feedback]))
