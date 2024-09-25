"""
osc_receiver.gd is based off OscReceiver.gd from Animatron by Roger Pibernat and Glenn Fraser.

https://github.com/loopier/animatron


MIT License

Copyright (c) 2023-present Roger Pibernat, Glen Fraser

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

"""

extends Node
class_name OscReceiver

class OscMessage:
	var addr: String
	var args: Array
	var semder: String # IP

signal osc_msg_received(addr: String, args: Array)

var socketUdp := PacketPeerUDP.new()
var streamBuf := StreamPeerBuffer.new()
var senderIP: String
var senderPort: int
enum {OSC_ARG_TYPE_NULL, OSC_ARG_TYPE_FLOAT=102, OSC_ARG_TYPE_INT=105, OSC_ARG_TYPE_STRING=115}
var observers: Dictionary = Dictionary()
var lastSentTarget

# osc server
var serverPort: int = 56101 :
	get = getServerPort,
	set = setServerPort

var oscBuf := StreamPeerBuffer.new()
var oscArgBuf := StreamPeerBuffer.new()

func _ready():
	oscBuf.big_endian = true
	oscArgBuf.big_endian = true
	streamBuf.big_endian = true


func startServer():
	var err := socketUdp.bind(serverPort)
	if err != 0:
		printerr("OSC ERROR while trying to listen on port: %s" % [serverPort])
	else:
		print("OSC server listening on port: %s" % [socketUdp.get_local_port()])

func startServerOn(listenPort: int):
	serverPort = listenPort
	startServer()

# 'delta' is the elapsed time since the previous update.
func _physics_process(_delta):
	var num_available_packets := socketUdp.get_available_packet_count()
	for i in num_available_packets:
		var msg := parseOsc(socketUdp.get_packet())
		# var sender := "%s/%d" % [socketUdp.get_packet_ip(), socketUdp.get_packet_port()]
		# Log.verbose("OSC message received from %s: %s %s" % [sender, msg.addr, msg.args])
		osc_msg_received.emit(msg.addr, msg.args)

func _exit_tree():
	socketUdp.close()
#	thread.wait_to_finish()

func setServerPort(port: int):
	serverPort = port
func getServerPort() -> int:
	return serverPort

func parseOsc(packet: PackedByteArray) -> OscMessage:
	streamBuf.set_data_array(packet)
	var addr := getString(streamBuf)
	# move the cursor to the beginning of the argument types string fs
	streamBuf.seek(getArgTypesIndex(streamBuf))
	# get the types
	var types := getString(streamBuf)
	# skip the leading ','
	var typeIndex := 1
	# get the current type
	var type := types.substr(typeIndex,1)
	# get the last position of the type string
	var end := streamBuf.get_position()
	# move the cursor to the next byte if the current one is not a multiple of 4
	var next := end if end % 4 == 0 else end + 4 - (end % 4)
	streamBuf.seek(next)
	# parse the arguments
	var args := []
	for i in streamBuf.get_size():
		type = types.substr(typeIndex, 1)
		match type:
			"i": args.append(getInt(streamBuf))
			"f": args.append(getFloat(streamBuf))
			"s": args.append(getString(streamBuf))
			"T": args.append(true)
			"F": args.append(false)
			"N": args.append(null)
			_: continue
		typeIndex += 1
#		print("OSC arg %s: %s(%s)" % [i, args.back(), type])
	
	var msg := OscMessage.new()
	msg.addr = addr
	msg.args = args
	
	return msg

func getString(buf: StreamPeer) -> String:
	var result := ""
	for i in buf.get_size():
		var c := buf.get_u8()
		# keep moving the cursor until the next multiple of 4
		if c == 0 and buf.get_position() % 4 == 0: break
		result += char(c)
	return result

func getFloat(buf: StreamPeer) -> float:
	return buf.get_float()
	
func getInt(buf: StreamPeer) -> int:
	return buf.get_32()
	
# osc messages define the arg types in a byte = 44 (,)
func getArgTypesIndex(buf: StreamPeer) -> int:
	return buf.get_data_array().find(",".to_ascii_buffer()[0])

func getArgs(_buf: StreamPeer) -> Array:
	return []

func addString(buf: StreamPeer, inStr: String):
	buf.put_data(inStr.to_ascii_buffer())
	var padding := 4 - inStr.length() % 4
	if padding == 4:
		buf.put_32(0)
	else:
		for i in range(padding):
			buf.put_8(0)

func sendMessage(target: String, oscAddr: String, oscArgs: Array):
	oscBuf.clear()
	oscArgBuf.clear()
	addString(oscBuf, oscAddr)
	var argTags := ","
	for arg in oscArgs:
		match typeof(arg):
			TYPE_FLOAT:
				argTags += "f"
				oscArgBuf.put_float(arg)
			TYPE_INT:
				argTags += "i"
				oscArgBuf.put_32(arg)
			TYPE_STRING, TYPE_STRING_NAME:
				argTags += "s"
				addString(oscArgBuf, arg)
			TYPE_BOOL:
				argTags += "T" if arg else "F"
			TYPE_NIL:
				argTags += "N"
			_:
				printerr("Unsupported OSC type: %s" % typeof(arg))				

	addString(oscBuf, argTags)
	oscBuf.put_data(oscArgBuf.data_array)
	
	if target != lastSentTarget:
		var addrPort := target.split("/")
		if addrPort.size() == 2:
			# Log.verbose("Replying %s to %s/%s" % [oscAddr, addrPort[0], addrPort[1] as int])
			socketUdp.set_dest_address(addrPort[0], addrPort[1] as int)
			lastSentTarget = target
	
	if lastSentTarget != null:
		socketUdp.put_packet(oscBuf.data_array)

#func _thread_function(userdata):
#	print("I'm a thread! Userdata is: ", userdata)
