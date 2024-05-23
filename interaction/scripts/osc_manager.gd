extends Node
class_name OSCManager

@export var sender_host: String = "127.0.0.1"
@export var sender_port: int = 57120

var _osc_impl: OscReceiver
var _target_string: String

func _ready():
	_osc_impl = OscReceiver.new()
	self.add_child.call_deferred(_osc_impl)
	print("OSC: Spawned OscReceiver Node")
	_target_string = sender_host + "/" + str(sender_port)

func _send(osc_addr: String, args: Array=[]):
	if _osc_impl == null: return
	_osc_impl.sendMessage(_target_string, osc_addr, args)

func send_code_command(receiver: String, payload: String):
	_send("/lc/command", [receiver, payload])
	print("Sent: /lc/command " + str([receiver, payload]))
