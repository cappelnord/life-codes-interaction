extends Node
class_name WebSocketController

static var run_id: String
static var _qr_node = preload("res://interaction/nodes/qr_node.tscn")

var _socket: WebSocketPeer
var _attempt_connection := true
var _connected := false
var _time_of_disconnect := -1
var _authenticated := false
var _json = JSON.new()
var _server_run_id: String
var _last_challenge := ""

var _secret: String

var _qr_slots: Array[QRCodeSlot] = []
var _qr_slots_lookup = {}
var _current_slot_index := 0
var _http_request

var _last_lifebeat_sent := -1
var _last_lifebeat_received := -1

var _ping_log_file
var _last_ping_sent := -1

@onready var _cursor_manager: CursorManager = $"../CursorManager"


func _spawn_qr_code(position: Vector2, target_size: int, id: String, style: StringName, scheme: String="default"):
	var node = _qr_node.instantiate() as QRCodeSlot
	node.id = id
	node.position = position
	node.target_size = target_size
	node.style = style
	node.scheme = scheme
	add_child(node)

func _load_secret()->bool:
	var file = FileAccess.open("./websocket_shared_secret.txt", FileAccess.READ)
	if not file:
		printerr("Could not load WebSocket server shared secret from ./websocket_shared_secret.txt ... will not attempt connectio to server.")
		return false
	else:
		_secret = file.get_as_text().strip_edges(true, true)
		return true

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Config.websocket_enable:
		queue_free()
		return
	
	if not _load_secret():
		queue_free()
		return
	
	if Config.websocket_record_ping_log:
		var path := "./ping_log.txt"
		
		if not FileAccess.file_exists(path):
			_ping_log_file = FileAccess.open(path, FileAccess.WRITE_READ)
		else:
			_ping_log_file = FileAccess.open(path, FileAccess.READ_WRITE)

		_ping_log_file.seek_end()

	
	_spawn_qr_code(Vector2(5350, 500), 150, "a", &"a");
	_spawn_qr_code(Vector2(5350, 700), 150, "b", &"b");
	_spawn_qr_code(Vector2(5550, 500), 150, "c", &"c");
	_spawn_qr_code(Vector2(5550, 700), 150, "d", &"d");
	
	if run_id == "":
		run_id = str(str(randf_range(0.0, 1.0)).hash())
		print("Initialized WebSocket Client with runID: " + run_id)
	
	_reset_http_request()


func _reset_http_request():
	if _http_request:
		_http_request.request_completed.disconnect(self._qr_code_download_completed)
		_http_request.cancel_request()
		_http_request.queue_free() 
		remove_child(_http_request)
	
	_http_request = HTTPRequest.new()
	 # while using threads is/was nice it created hangs when downloads timed out
	_http_request.use_threads = false
	_http_request.set_timeout(10)
	add_child(_http_request)
	_http_request.request_completed.connect(self._qr_code_download_completed)
	

func _salted_hash(data)->String:
	return (data + _secret).md5_text() as String

func register_slot(qr_slot: QRCodeSlot):
	# print(slot.slot_id)
	_qr_slots.append(qr_slot)
	_qr_slots_lookup[qr_slot.id] = qr_slot

# TODO: Should the packet processing be moved to physics_process?
# --> Probably try! We can save a frame of input latency (at least if nothing is blocking)
# --> Maybe monitor if things are blocking here; Websocket processing would be a good candidate
#     to offload to another thread.

func _process(delta):
	if not _socket and _attempt_connection:
		_attempt_connect_websocket()
	else:
		_socket.poll()
		var state = _socket.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			if not _connected: _connection_established()
			
			while _socket.get_available_packet_count():
				_process_packet(_socket.get_packet())
			
			_send_lifebeat()
			_check_for_lifebeat()
			if Config.websocket_record_ping_log:
				_send_ping()
			
		elif state == WebSocketPeer.STATE_CLOSING:
			print("WebSocketPeer State: Closing")
			# controversial if it is needed or not - maybe not.
			while _socket.get_available_packet_count():
				_socket.get_packet()
		elif state == WebSocketPeer.STATE_CLOSED:
			if _connected:
				var code = _socket.get_close_code()
				var reason = _socket.get_close_reason()
				print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			_clear_websocket()
	
	if _connected and _authenticated:
		_process_slots()

	if _time_of_disconnect > 0 and (_time_of_disconnect + (Config.websocket_time_until_long_disconnect * 1000)) < Time.get_ticks_msec():
		print("Disconnected to WebSocket server already for some time. Hard reset QR code slots.")
		for qr_slot in _qr_slots:
			_hard_reset_qr_slot(qr_slot)
		_time_of_disconnect = -1

func _check_for_lifebeat():
	if not _connected: return
	
	if _last_lifebeat_received + (Config.websocket_time_until_lifebeat_timeout * 1000) < Time.get_ticks_msec():
		_lifebeat_timeout()
	
func _lifebeat_timeout():
	print("lifeBeat timeout ...")
	_socket.close()
	_clear_websocket()
	_server_has_restarted()

func _send_ping():
	if not _connected or not Config.websocket_record_ping_log: return
	
	if _last_ping_sent + 1000 < Time.get_ticks_msec():
		_last_ping_sent = Time.get_ticks_msec()
		_socket.send_text(JSON.stringify({"cmd": "ping", "payload": Time.get_ticks_msec()}))

func _send_lifebeat():
	if not _connected: return
	
	if _last_lifebeat_sent + (Config.websocket_lifebeat_interval * 1000) < Time.get_ticks_msec():
		_last_lifebeat_sent = Time.get_ticks_msec()
		_socket.send_text(JSON.stringify({"cmd": "lifeBeat"}))

func _process_slots():
	if _qr_slots.size() == 0: return
	if _qr_slots[_current_slot_index].pending: return
	var start_index = _current_slot_index

	while true:
		if _qr_slots[_current_slot_index].requires_action:
			_refresh_current_slot()
			return
		_current_slot_index = (_current_slot_index + 1) % _qr_slots.size()
		if _current_slot_index == start_index: return

func _refresh_current_slot():
	_qr_slots[_current_slot_index].stop_loading()
	_qr_slots[_current_slot_index].pending = true
	
	#if Config.debug_verbose:
		#print("Requesting requestToken for slot: " + _qr_slots[_current_slot_index].id)
	
	_socket.send_text(JSON.stringify({"cmd": "request", "slot": _qr_slots[_current_slot_index].id, "scheme": _qr_slots[_current_slot_index].scheme}))


func _attempt_connect_websocket():
	var websocket_url = Config.websocket_base_url + Config.websocket_installation_path
	websocket_url = websocket_url.replacen("http://", "ws://").replacen("https://", "wss://")
	
	_socket = WebSocketPeer.new()
	_socket.connect_to_url(websocket_url)
	

func _clear_websocket():
	_socket = null

	if _connected:
		_time_of_disconnect = Time.get_ticks_msec()

	_connected = false
	
	_reset_http_request()
	
	for qr_slot in _qr_slots:
		if qr_slot.spawned:
			_cursor_manager.user_disconnected(qr_slot.id)
	
func _connection_established():
	_connected = true
	_time_of_disconnect = -1
	_socket.set_no_delay(true)
	
	_last_lifebeat_sent = -1
	_last_lifebeat_received = Time.get_ticks_msec()

	for qr_slot in _qr_slots:
		qr_slot.pending = false # if a new QR code is needed then they should now try to get it
		
		# see that the user_connected flag is set in case we recover from a disconnect
		if qr_slot.spawned:
			_cursor_manager.user_connected(qr_slot.id)
		
	print("Connected to WebSocket")

func _process_packet(packet: PackedByteArray):
	var valid_json = _json.parse(packet.get_string_from_ascii())
	if valid_json == OK:
		var msg = _json.data
		if "cmd" in msg:
			_process_msg(msg)
		else:
			print("Non-conforming JSON message received: " + msg)
	else:
		print("Could not decode JSON message from WebSocket: " + packet.get_string_from_ascii())

func _process_msg(msg: Variant):
	
	# all messages here have a cmd - in particular challenge and hello are susceptible 
	
	if msg.cmd == "challenge":
		_process_challenge_msg(msg)
		return
	if msg.cmd == "hello":
		_process_hello_msg(msg)
		return
	
	if not _authenticated:
		print("Received message without authentication")
		return
	
	match msg.cmd:
		"lifeBeat":
			_process_lifebeat_msg(msg)
		"pong":
			_process_pong(msg)
		"qr":
			_process_qr_msg(msg)
		"slotControlIssued":
			_process_slot_control_issued_msg(msg)
		"slotControlReleased":
			_process_slot_control_released_msg(msg)
		"cursorUserConnected":
			_process_cursor_user_connected(msg)
		"cursorUserDisconnected":
			_process_cursor_user_disconnected(msg)
		"cursorSpawn":
			_process_cursor_spawn(msg)
		"cursorMoveDelta":
			_process_cursor_move_delta(msg)
		"cursorPress":
			_process_cursor_press(msg)
		"cursorRelease":
			_process_cursor_release(msg)
		"cursorAttemptToggleGrab":
			_process_cursor_attempt_toggle_grab(msg)
		"cursorDeviceOrientation":
			_process_cursor_device_orientation(msg)

func _process_pong(msg: Variant):
	if not Config.websocket_record_ping_log: return

	var rtt := Time.get_ticks_msec() - msg["payload"] as int
	_ping_log_file.store_line(JSON.stringify({"type": "ping", "utc": Time.get_datetime_string_from_system(true), "rtt": rtt }))
	_ping_log_file.flush()

func _process_lifebeat_msg(msg: Variant):
	_last_lifebeat_received = Time.get_ticks_msec()

func _process_challenge_msg(msg: Variant):
	var challenge_response := _salted_hash(msg.get("challenge", ""))
	_last_challenge = str(str(randf_range(0.0, 1.0)).hash())
	
	_socket.send_text(JSON.stringify({"cmd": "challengeAccepted", "payload": challenge_response, "challenge": _last_challenge, "run_id": run_id}))

func _process_hello_msg(msg: Variant):
	
	_authenticated = _salted_hash(_last_challenge) == msg.get("payload", "")
	
	if(not _authenticated):
		printerr("Failed authentification with server .. most likely the shared secret does not match.")
	
	if _server_run_id != "" and msg.get("run_id", "") != _server_run_id:
		_server_has_restarted()
	
	_server_run_id = msg.run_id

func _process_qr_msg(msg: Variant):
	if _qr_slots[_current_slot_index].id != msg.slot:
		print("Received qr message that does not correspond to current slot.")
		return
	
	_reset_http_request()
	
	#if Config.debug_verbose:
		#print("Requesting QR code for slot: " + msg.slot)
	
	var error = _http_request.request(msg.url)
	if error != OK:
		print("An error occurred in the HTTP request.")
		_qr_slots[_current_slot_index].pending = false

func _qr_code_download_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Failed downloading QR code - Result Code: " + str(result))
		_qr_slots[_current_slot_index].pending = false
		return		
	
	if response_code != 200:
		print("Server did not respond with status code 200 - could not download QR code. Code: " + str(response_code))
		_qr_slots[_current_slot_index].pending = false
		return
	
	var image = Image.new()
	var image_error = image.load_png_from_buffer(body)
	
	if image_error != OK:
		print("Couldn't load the image.")
		_qr_slots[_current_slot_index].pending = false
		return
		
	#if Config.debug_verbose:
		#print("Rotate QR code for slot: " + _qr_slots[_current_slot_index].id)
		#print("---")

	_qr_slots[_current_slot_index].update_qr_code(image)
	
func _process_slot_control_issued_msg(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot:
		slot.slot_control_issued()

func _process_slot_control_released_msg(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot:
		if slot.spawned:
			_cursor_manager.despawn(slot.id)
		slot.slot_control_released()

func _process_cursor_spawn(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and not slot.spawned:
		slot.spawn()
		var cursor := _cursor_manager.spawn(slot.id, slot.position, Config.websocket_display_cursor_hint, slot.style)
		cursor.feedback.connect(_on_cursor_feedback)
		cursor.user_progress.progress.connect(_on_user_progress)

func _process_cursor_move_delta(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and slot.spawned:
		
		# we had a case of invalid numbers here. While this ideally is already caught
		# in the browser and/or server we should also validate it here.
		
		var x := 0.0
		var y := 0.0
		
		if typeof(msg.x) == TYPE_FLOAT || typeof(msg.x) == TYPE_INT:
			x = msg.x
		if typeof(msg.y) == TYPE_FLOAT || typeof(msg.y) == TYPE_INT:
			y = msg.y		
		
		_cursor_manager.move_delta(slot.id, Vector2(x, y) * Config.websocket_cursor_speed_modifier)

func _process_cursor_press(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and slot.spawned:
		_cursor_manager.press(slot.id)

func _process_cursor_release(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and slot.spawned:
		_cursor_manager.release(slot.id)
		
func _process_cursor_attempt_toggle_grab(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and slot.spawned:
		_cursor_manager.attempt_toggle_grab(slot.id)

func _process_cursor_user_connected(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and slot.spawned:
		_cursor_manager.user_connected(slot.id)	

func _process_cursor_user_disconnected(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and slot.spawned:
		_cursor_manager.user_disconnected(slot.id)	

func _process_cursor_device_orientation(msg: Variant):
	var slot = _qr_slots_lookup[msg.slot]
	if slot and slot.spawned:
		_cursor_manager.device_orientation(slot.id, msg.absolute, msg.alpha, msg.beta, msg.gamma)

func _hard_reset_qr_slot(qr_slot: QRCodeSlot):
	if qr_slot.spawned:
		_cursor_manager.despawn(qr_slot.id)
	qr_slot.reset()

func _server_has_restarted():
	print("Server has restarted since last connection. Hard Reset.")
	for qr_slot in _qr_slots:
		_hard_reset_qr_slot(qr_slot)

func _on_cursor_feedback(cursor_id: String, feedback: Cursor.Feedback):
	if _connected:
		_socket.send_text(JSON.stringify({"cmd": "feedbackCursor", "slot": cursor_id,  "feedback": Cursor.Feedback.keys()[feedback]}))

func _on_user_progress(cursor_id: String, progress: CursorUserProgress.Progress):
	if _connected:
		_socket.send_text(JSON.stringify({"cmd": "feedbackUserProgress", "slot": cursor_id, "userProgress": CursorUserProgress.Progress.keys()[progress]}))
