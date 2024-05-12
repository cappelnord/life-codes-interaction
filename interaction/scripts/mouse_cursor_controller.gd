extends Node

@onready var _manager: CursorManager = $"../CursorManager"

@export var enabled: bool = true
@export var id: String = "mouse"
@export var delta_multiplier: float = 1.0

var _active = false
var _lastPosition : Vector2 =  Vector2(100, 100)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not enabled:
		print("Removed MouseCursorController")
		queue_free()
		return

func _unhandled_input(event):
	if _active:
		if event is InputEventMouseMotion:
			_manager.move_delta(id, event.relative * delta_multiplier)
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_manager.press(id)
				else:
					_manager.release(id)

func _process(delta):
	if Input.is_action_just_pressed("toggle_mouse_cursor") or (Input.is_action_just_pressed("escape") and _active):
		if(not _active): _activate()
		else: _deactivate()

func _activate():
	_manager.spawn(id, _lastPosition)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_active = true

func _deactivate():
	var cursor : Cursor = _manager.get_cursor(id)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if cursor != null:
		_lastPosition = cursor.position
	_manager.despawn(id)
	_active = false
