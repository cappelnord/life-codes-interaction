extends Sprite2D
class_name Cursor

var id: String

var _manager: CursorManager

var _time_when_reset = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	_manager = (get_parent() as CursorManager)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _time_when_reset > 0 and Time.get_ticks_msec() > _time_when_reset:
		texture = _manager.cursor_image_base
		_time_when_reset = -1 

func move_delta(delta: Vector2):
	var new_position : Vector2 = position + delta
	
	# TODO: Limit in extends

	position = new_position
	
	# TODO: Move in case something got attached

# a cursor control scheme should either do one or the other - do not mix these up!
# in the end it should translate to attach/unattach if feasible

func press():
	texture = _manager.cursor_image_attempt_grab

func release():
	texture = _manager.cursor_image_base

func attempt_toggle_grab():
	texture = _manager.cursor_image_attempt_grab
	_time_when_reset = Time.get_ticks_msec() + 500
