extends Object
class_name CursorUserProgress

enum Progress {
	HELLO,
	DID_MOVE,
	DID_GRAB,
	DID_CONNECT_BLOCK,
	NOTHING
}

signal progress(cursor_id: String, state: Progress)

const DID_MOVE_TIME := 300
const TIME_UNTIL_NOTHING = 8000

var cursor_id: String

var _first_move_time := -1
var _did_move := false
var _did_grab := false
var _did_connect_block := false
var _did_connect_block_time := -1
var _did_finish := false

func process(delta):
	if _did_connect_block and not _did_finish:
		if _did_connect_block_time + TIME_UNTIL_NOTHING < Time.get_ticks_msec():
			_did_finish = true
			progress.emit(cursor_id, Progress.NOTHING)

func _init(cursor_id: String):
	self.cursor_id = cursor_id

func cursor_did_move():
	if not _did_move:
		var time := Time.get_ticks_msec()
		if _first_move_time < 0: _first_move_time = time
		if _first_move_time + DID_MOVE_TIME < time:
			_did_move = true
			progress.emit(cursor_id, Progress.DID_MOVE)

func cursor_did_grab():
	if _did_move and not _did_grab:
		_did_grab = true
		progress.emit(cursor_id, Progress.DID_GRAB)

func cursor_did_connect_block():
	if _did_grab and not _did_connect_block:
		_did_connect_block = true
		progress.emit(cursor_id, Progress.DID_CONNECT_BLOCK)
		_did_connect_block_time = Time.get_ticks_msec()
