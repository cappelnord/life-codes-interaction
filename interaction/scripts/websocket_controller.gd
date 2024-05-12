extends Node
class_name WebSocketController

@export var base_websocket_url: String = "http://localhost:8000"
@export var installation_websocket_path: String = "/ws/installation"

static var run_id: String

var _socket: WebSocketPeer
var _attempt_connection = true
var _connected = false
var _authenticated = false
var _json = JSON.new()
var _server_run_id: String

var _slots = []
var _slots_lookup = {}
var _current_slot_index = 0
var _http_request

# Called when the node enters the scene tree for the first time.
func _ready():
	if run_id == "":
		run_id = str(str(randf_range(0.0, 1.0)).hash())
		print("Initialized WebSocket Client with runID: " + run_id)
	
	_http_request = HTTPRequest.new()
	_http_request.use_threads = true
	add_child(_http_request)
	_http_request.request_completed.connect(self._qr_code_download_completed)


func register_slot(slot: QRCodeSlot):
	# print(slot.slot_id)
	_slots.append(slot)
	_slots_lookup[slot.id] = slot

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
		elif state == WebSocketPeer.STATE_CLOSING:
			# Keep polling to achieve proper close.
			pass
		elif state == WebSocketPeer.STATE_CLOSED:
			if _connected:
				var code = _socket.get_close_code()
				var reason = _socket.get_close_reason()
				print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			_clear_websocket()
	
	if _connected and _authenticated:
		_process_slots()

func _process_slots():
	if _slots.size() == 0: return
	if _slots[_current_slot_index].pending: return
	var start_index = _current_slot_index

	while true:
		if _slots[_current_slot_index].requires_action:
			_refresh_current_slot()
			return
		_current_slot_index = (_current_slot_index + 1) % _slots.size()
		if _current_slot_index == start_index: return

func _refresh_current_slot():
	_slots[_current_slot_index].pending = true
	_socket.send_text(JSON.stringify({"cmd": "request", "slot": _slots[_current_slot_index].id}))


func _attempt_connect_websocket():
	var websocket_url = base_websocket_url + installation_websocket_path
	websocket_url = websocket_url.replacen("http://", "ws://").replacen("https://", "wss://")
	
	_socket = WebSocketPeer.new()
	_socket.connect_to_url(websocket_url)
	

func _clear_websocket():
	_socket = null
	_connected = false
	
func _connection_established():
	_connected = true

	for slot in _slots:
		slot.pending = false
		
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
	print(msg)
	
	# messages that must be processed before auth
	
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
		"qr":
			_process_qr_msg(msg)
		"slotControlIssued":
			_process_slot_control_issued_msg(msg)

func _process_challenge_msg(msg: Variant):
	# TODO: do the challenge
	_socket.send_text(JSON.stringify({"cmd": "challengeAccepted", "payload": "...", "challenge": "...", "run_id": run_id}))

func _process_hello_msg(msg: Variant):
	# TODO: check authentification
	_authenticated = true
	
	if _server_run_id != "" and msg.run_id != _server_run_id:
		_server_has_restarted()
	
	_server_run_id = msg.run_id

func _process_qr_msg(msg: Variant):
	if _slots[_current_slot_index].id != msg.slot:
		print("Received qr message that does not correspond to current slot.")
		return
	
	_http_request.cancel_request()
	
	var error = _http_request.request(msg.url)
	if error != OK:
		print("An error occurred in the HTTP request.")
		_slots[_current_slot_index].pending = true

func _qr_code_download_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Failed downloading QR code.")
		_slots[_current_slot_index].pending = true
		return		
	
	if response_code != 200:
		print("Server did not respond with status code 200 - could not download QR code. Code: " + str(response_code))
		_slots[_current_slot_index].pending = true
		return
	
	var image = Image.new()
	var image_error = image.load_png_from_buffer(body)
	
	if image_error != OK:
		print("Couldn't load the image.")
		_slots[_current_slot_index].pending = true
		return

	var texture = ImageTexture.create_from_image(image)
	_slots[_current_slot_index].update_qr_code(texture)
	
func _process_slot_control_issued_msg(msg: Variant):
	var slot = _slots_lookup[msg.slot]
	if slot:
		slot.slot_control_issued()

func _server_has_restarted():
	print("Server has restarted since last connection. Resetting data.")
	for slot in _slots:
		slot.reset()
