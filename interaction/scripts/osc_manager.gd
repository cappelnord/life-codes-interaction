extends Node
class_name OSCManager

var _osc_impl: OscReceiver
var _target_string: String
var _code_block_manager: CodeBlockManager

func _ready():
	_osc_impl = OscReceiver.new()
	self.add_child.call_deferred(_osc_impl)
	print("OSC: Spawned OscReceiver Node")
	_target_string = InteractionConfig.OSC_SENDER_HOST + "/" + str(InteractionConfig.OSC_SENDER_PORT)
	_osc_impl.setServerPort(InteractionConfig.OSC_RECEIVER_PORT)
	_osc_impl.startServer()
	_osc_impl.osc_msg_received.connect(_on_osc_msg_received)
	
func init_with_code_block_manager(manager: CodeBlockManager):
	_code_block_manager = manager

func _send(osc_addr: String, args: Array=[]):
	if _osc_impl == null: return
	_osc_impl.sendMessage(_target_string, osc_addr, args)

func send_code_command(receiver: String, payload: String, commit_id: int):
	var array = [receiver, payload, commit_id]
	_send("/lc/command", array)
	print("Sent: /lc/command " + str(array))

func _on_osc_msg_received(addr: String, args: Array, sender: String):
	if _code_block_manager == null: return
	
	match addr:
		"/lc/back/commitExecuted":
			_code_block_manager.on_received_commit_executed(args[0] as String, args[1] as int)
		_:
			print("No OSC route for: " + addr)
