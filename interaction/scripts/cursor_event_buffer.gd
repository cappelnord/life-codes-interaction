extends Object
class_name CursorEventBuffer

var _buffer_size := 4096
var _buffer: Array[CursorEvent] = []
var _read_pointer := 0
var _write_pointer := 0

func _init():	
	for i in _buffer_size:
		_buffer.append(CursorEvent.new(CursorEvent.Type.MOVE_DELTA))

func write_event(type: CursorEvent.Type, vector: Vector2 = Vector2.ZERO):
	_buffer[_write_pointer].type = type
	_buffer[_write_pointer].vector = vector	
	_write_pointer = (_write_pointer + 1) % _buffer_size

func read_next_move_event()->CursorEvent:
	if _read_pointer == _write_pointer: return null
	var event := _buffer[_read_pointer]
	if event.type == CursorEvent.Type.MOVE or event.type == CursorEvent.Type.MOVE_DELTA:
		_read_pointer = (_read_pointer + 1) % _buffer_size
		return event
	else:
		return null

func read_next_action_event()->CursorEvent:
	if _read_pointer == _write_pointer: return null
	var event := _buffer[_read_pointer]
	if event.type != CursorEvent.Type.MOVE and event.type != CursorEvent.Type.MOVE_DELTA:
		_read_pointer = (_read_pointer + 1) % _buffer_size
		return event
	else:
		return null
