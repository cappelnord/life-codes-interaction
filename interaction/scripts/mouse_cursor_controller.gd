extends Node
class_name MouseCursorController

@onready var _manager: CursorManager = $"../CursorManager"

@export var id: String = "mouse"


var _active = false
var _last_position : Vector2 =  Vector2(100, 100)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Config.mouse_enable:
		print("Removed MouseCursorController")
		queue_free()
		return

func _unhandled_input(event):
	if _active:
		if event is InputEventMouseMotion:
			_manager.move_delta(id, event.relative * Config.mouse_speed)
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_manager.press(id)
				else:
					_manager.release(id)
	else:
		if event is InputEventMouseMotion:
			_last_position = event.position * Config.mouse_viewport_modifier

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_M or event.keycode == KEY_ESCAPE and _active:
			if(not _active): _activate()
			else: _deactivate()

func _activate():
	var cursor := _manager.spawn(id, _last_position)
	cursor.user_progress.progress.connect(_on_user_progress)
	cursor.feedback.connect(_on_cursor_feedback)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_active = true

func _deactivate():
	var cursor : Cursor = _manager.get_cursor(id)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if cursor != null:
		_last_position = cursor.position
	_manager.despawn(id)
	_active = false

func _on_user_progress(cursor_id: String, progress: CursorUserProgress.Progress):
	print("User Progress: " + str(CursorUserProgress.Progress.keys()[progress]))

func _on_cursor_feedback(cursor_id: String, feedback: Cursor.Feedback):
	print("Cursor Feedback: " + str(Cursor.Feedback.keys()[feedback]))
