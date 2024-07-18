extends Node2D
class_name CodeBlockManager


var _code_block_node = preload("res://interaction/nodes/code_block_node.tscn")

var _specs: Dictionary = {}
var _slots: Dictionary = {}
var _families: Dictionary = {}

@onready var _osc: OSCManager = $"../OSCManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	_osc.set_code_block_manager(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# iterate over slots and instantiate blocks if needed
	for id in _slots:
		var slot: CodeBlockSlot = _slots[id]
		if slot.should_spawn():
			slot.block = _code_block_node.instantiate() as CodeBlock
			slot.block.slot = slot # the codeblock will take care of reading everything from the slot
			add_child(slot.block)
	
	CodeBlockVisual.oscillation_phase = fmod(CodeBlockVisual.oscillation_phase + Config.code_blocks_oscillation_hz * TAU * delta, TAU)

func add_spec(spec: CodeBlockSpec)->CodeBlockSpec:
	_specs[spec.id] = spec
	return spec

func get_spec(id: StringName)->CodeBlockSpec:
	return _specs[id]

func add_family(family: CodeBlockFamily)->CodeBlockFamily:
	_families[family.id] = family
	return family

func get_family(id: StringName)->CodeBlockFamily:
	return _families[id]

func add_slot(slot: CodeBlockSlot)->CodeBlockSlot:
	slot.manager = self
	_slots[slot.id] = slot
	return slot
	
func get_slot(id: StringName)->CodeBlockSlot:
	return _slots[id]

func get_block(id: StringName)->CodeBlock:
	var slot = get_slot(id)
	if slot != null:
		return slot.block
	else:
		return null

func get_group(id: StringName)->CodeBlockGroup:
	var block = get_block(id)
	if block != null and block.group != null:
		return block.group
	else:
		return null

func on_group_comitted(group: CodeBlockGroup):
	_osc.send_code_command(group.head.slot.get_command_context(), _compile_code_string(group), group.head.slot.id, group.last_command_id)

func _compile_code_string(group: CodeBlockGroup)->String:
	var ret: String = group.head.code_string
	if group.action != null:
		ret = ret + ";" + group.action.code_string
	for modifer in group.modifiers:
		ret = ret + ";" + modifer.code_string
	# print("Compiled code string: " + ret)
	return ret

func on_received_command_feedback(id: String, command_id: String):
	var group := get_group(id)
	if group != null:
		group.on_command_feedback(command_id)

func on_received_load_specs(path: String):
	print("Loading specs from: " + path + " ...")
	_wipe()
	(CodeBlockLoader.new()).loadJSON(path, self)

func on_received_add_slot(json_string: String):
	var data = JSON.parse_string(json_string)
	print(data)
	var slot = CodeBlockSlot.from_json(data, self)
	if slot:
		add_slot(slot)
	

# this will be called when specs are (re)loaded to make sure that no old stuff is lingering around.
# this will not call the gracious "dismiss" on the blocks but will terminate things quickly
func _wipe():
	# let's start with slots/blocks
	for key in _slots.keys():
		_slots[key].delete()
	_slots = {}
	
	# I assume here the GC should be sufficient in dealing with things
	_specs = {}
	_families = {}
	
