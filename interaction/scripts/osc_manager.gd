extends Node
class_name OSCManager

var _osc_impl: OscReceiver
var _target_string: String
var _code_block_manager: CodeBlockManager
var _osc_cursor_controller: OSCCursorController

func _ready():
	_osc_impl = OscReceiver.new()
	self.add_child.call_deferred(_osc_impl)
	print("OSC: Spawned OscReceiver Node")
	_target_string = Config.osc_receiver_host + "/" + str(Config.osc_receiver_port)
	_osc_impl.setServerPort(Config.osc_listen_port)
	_osc_impl.startServer()
	_osc_impl.osc_msg_received.connect(_on_osc_msg_received)
	
func set_code_block_manager(manager: CodeBlockManager):
	_code_block_manager = manager
	
func set_osc_cursor_controller(controller: OSCCursorController):
	_osc_cursor_controller = controller

func _send(osc_addr: String, args: Array=[]):
	if _osc_impl == null: return
	_osc_impl.sendMessage(_target_string, osc_addr, args)

func send_code_command(receiver: String, payload: String, commit_id: int):
	var array = [receiver, payload, commit_id]
	_send("/lc/command", array)
	print("Sent: /lc/command " + str(array))

func _on_osc_msg_received(addr: String, args: Array):
	
	if _code_block_manager != null:
		match addr:
			"/lc/blocks/commandFeedback":
				_code_block_manager.on_received_command_feedback(args[0] as String, args[1] as int)
			"/lc/blocks/loadSpecs":
				_code_block_manager.on_received_load_specs(args[0] as String)
	
	if _osc_cursor_controller != null and addr.begins_with(OSCCursorController.ADDR_PATTERN_ROOT):
		_osc_cursor_controller.on_osc_msg_received(addr, args)
