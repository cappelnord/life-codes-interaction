extends Sprite2D
class_name QRCodeSlot

@export var id: String
@export var scheme: String = "default"
@export var style: String = "a"
@export var target_size: int = 120

var pending := false # if it is inbetween, waiting for an QR code to be assigned
var requires_action := true # waiting to be in line to receive a new QR code
var under_control := false # control was issued by the server
var loading := false # waiting for the client to spawn the cursor
var spawned := false # the cursor is spawned and represented by its own cursor object

var _loading_node_instance = null
var _loading_node = preload("res://interaction/nodes/loading_rotate_node.tscn")


var _last_refresh : int = -1
var _loading_timeout : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = Config.Z_INDEX_QR_CODE
	(get_parent() as WebSocketController).register_slot(self)
	_update_scale()
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if loading and Time.get_ticks_msec() > _loading_timeout:
		reset()
	
	if not pending and not requires_action and not under_control:
		if Time.get_ticks_msec() > _last_refresh + (Config.websocket_time_until_code_refresh * 1000):
			requires_action = true

func _update_scale():
	scale = Vector2(target_size, target_size) / texture.get_width()

func update_qr_code(texture: ImageTexture):
	set_texture(texture)
	_update_scale()
	_last_refresh = Time.get_ticks_msec()
	pending = false
	requires_action = false
	show()

func slot_control_issued():
	under_control = true
	start_loading()

func slot_control_released():
	stop_loading()
	spawned = false
	under_control = false
	pending = false
	requires_action = true	

func spawn():
	stop_loading()
	spawned = true

func start_loading():
	stop_loading() # to be sure that any old node is removed
	loading = true
	_loading_timeout = Time.get_ticks_msec() + (Config.websocket_time_until_loading_timeout * 1000)
	_loading_node_instance = _loading_node.instantiate()
	get_parent().add_child.call_deferred(_loading_node_instance)
	(_loading_node_instance as Sprite2D).position = position
	hide()
	

func stop_loading():
	if not _loading_node_instance == null:
		_loading_node_instance.queue_free()
		_loading_node_instance = null
	_loading_timeout = -1
	loading = false

func reset():
	pending = false
	requires_action =  true
	spawned = false
	under_control = false
	stop_loading()
