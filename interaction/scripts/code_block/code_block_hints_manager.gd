extends Node
class_name CodeBlockHintsManager

@onready var _hint_node = preload("res://interaction/nodes/code_block_hint.tscn")
@onready var _cursor_hint_node = preload("res://interaction/nodes/cursor_hint.tscn")

var hints: Array[StringName] = []
var interval := 10
var _next_hint_time = -1

@onready var _code_block_manager: CodeBlockManager = $"../../CodeBlockManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hints.size() == 0: return
	if _next_hint_time == -1: return
	
	if Time.get_ticks_msec() >= _next_hint_time:
		_hint()

func cursor_hint(cursor: Cursor):
	var hint = _cursor_hint_node.instantiate() as CursorHint
	hint.cursor = cursor
	add_child(hint)

func _schedule_hints():
	if interval > 0:
		_next_hint_time = Time.get_ticks_msec() + interval * 1000

func _hint():
	if hints.size() == 0: return
	
	_schedule_hints()
	
	var has_subject = false
	var hints_to_emit := []

	for blockId in hints:
		var block = _code_block_manager.get_block(blockId)
		if block == null:
			continue
		if block.grabbed or block.despawning:
			continue
		if (not block.slot.spec.head_role()) and (block.group != null):
			continue
		
		if block.slot.spec.head_role():
			has_subject = true
		
		hints_to_emit.append(blockId)
	
	if not has_subject or hints_to_emit.size() < 2:
		return
	
	var delay := 0.0
	for blockId in hints_to_emit:
		var block = _code_block_manager.get_block(blockId)
		var hint = _hint_node.instantiate() as CodeBlockHint
		hint.block = block
		hint.delay = delay
		add_child(hint)
		delay = delay + 0.25

func clear():
	hints.clear()
	_next_hint_time = -1

func wipe():
	clear()
	for n in get_children():
		remove_child(n)
		n.queue_free()

func on_received_hints(payload: String):
	var json = JSON.parse_string(payload)
	
	var data = json.get("hints", [])
	interval = json.get("interval", interval)
	
	clear()

	for entry in data:
		hints.append(StringName(entry))
	
	_schedule_hints()

func on_received_clear_hints():
	clear()

func on_received_trigger_hints():
	_hint()
