extends Sprite2D
class_name Cursor

var id: String
var _manager: CursorManager
var _time_when_reset = -1

var _hover_block: CodeBlock = null
var _grab_block: CodeBlock = null
var _pressed: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = InteractionConfig.Z_INDEX_MOUSE_CURSOR
	_manager = (get_parent() as CursorManager)
	($"CursorCollider" as Area2D).area_entered.connect(_on_area_entered)
	($"CursorCollider" as Area2D).area_exited.connect(_on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _time_when_reset > 0 and Time.get_ticks_msec() > _time_when_reset:
		_update_cursor_texture()
		_time_when_reset = -1 

func move(new_position: Vector2):
	position = new_position

func move_delta(delta: Vector2):
	var new_position : Vector2 = position + delta
	
	# TODO: Limit in extends

	position = new_position
	
	# TODO: Move in case something got attached

# a cursor control scheme should either do one or the other - do not mix these up!
# in the end it should translate to attach/unattach if feasible

func press():
	_pressed = true
	_update_cursor_texture()

func release():
	texture = _manager.cursor_image_base
	_pressed = false

func _update_cursor_texture():
	if _pressed:
		texture = _manager.cursor_image_attempt_grab
		return
	if _hover_block != null:
		texture = _manager.cursor_image_hover
	else:
		texture = _manager.cursor_image_base
		

func attempt_toggle_grab():
	texture = _manager.cursor_image_attempt_grab
	_time_when_reset = Time.get_ticks_msec() + 500

func _on_area_entered(collider: CodeBlockCollider):
	var success = collider.block.on_cursor_entered(self)
	if success:
		_hover_block = collider.block
	_update_cursor_texture()
	
func _on_area_exited(collider: CodeBlockCollider):
	collider.block.on_cursor_exited(self)
	_hover_block = null
	_update_cursor_texture()

func cleanup():
	if _hover_block != null:
		_hover_block.on_cursor_exited(self)
