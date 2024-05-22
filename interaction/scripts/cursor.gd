extends Sprite2D
class_name Cursor

var id: String
var _manager: CursorManager
var _time_when_reset = -1

var _hover_block: CodeBlock = null
var _grab_block: CodeBlock = null
var _pressed: bool = false

@onready var _collider: Area2D = $"CursorCollider"


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = InteractionConfig.Z_INDEX_MOUSE_CURSOR
	_manager = (get_parent() as CursorManager)
	_collider.area_entered.connect(_on_area_entered)
	_collider.area_exited.connect(_on_area_exited)

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
	
	if _grab_block != null:
		_grab_block.move_delta(delta)

# a cursor control scheme should either do one or the other - do not mix these up!
# in the end it should translate to attach/unattach if feasible

func press():
	_pressed = true
	_attempt_grab()
	_update_cursor_texture()

func release():
	_pressed = false
	_release_grab()
	_update_cursor_texture()
	if _hover_block == null: _attempt_rehover()

func _update_cursor_texture():
	if _grab_block != null:
		texture = _manager.cursor_image_grab
		return
	if _pressed:
		texture = _manager.cursor_image_attempt_grab
		return
	if _hover_block != null:
		texture = _manager.cursor_image_hover
	else:
		texture = _manager.cursor_image_base
		

func attempt_toggle_grab():
	texture = _manager.cursor_image_attempt_grab
	if not _attempt_grab(): _time_when_reset = Time.get_ticks_msec() + 500

func _attempt_grab():
	if _hover_block == null: return false
	var success = _hover_block.attempt_grab(self)
	if success:
		_grab_block = _hover_block
		return true
	return false
	
func _release_grab():
	if _grab_block != null:
		_grab_block.release_grab(self)
	_grab_block = null

func _on_area_entered(collider: CodeBlockCollider):
	if _pressed: return false
	if _hover_block != null: return false
	var success = collider.block.attempt_hover(self)
	if success:
		_hover_block = collider.block
	_update_cursor_texture()
	return success
	
func _on_area_exited(collider: CodeBlockCollider):
	collider.block.release_hover(self)
	_hover_block = null
	_attempt_rehover()
	_update_cursor_texture()

func cleanup():
	_release_grab()
	if _hover_block != null:
		_hover_block.release_hover(self)

func _attempt_rehover():
	var areas = _collider.get_overlapping_areas()
	for area in areas:
		if _on_area_entered(area): return 

	
