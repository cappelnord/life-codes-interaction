extends Node2D
class_name CodeBlockManager

var _code_block_node = preload("res://interaction/nodes/code_block.tscn")

var _specs: Dictionary = {}
var _slots: Dictionary = {}
var _families: Dictionary = {}

@onready var _osc: OSCManager = $"../OSCManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	_osc.init_with_code_block_manager(self)
	# load all specs
	CodeBlockLoader.new("..").load(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# iterate over slots and instantiate blocks if needed
	for id in _slots:
		var slot: CodeBlockSlot = _slots[id]
		if slot.should_spawn():
			slot.block = _code_block_node.instantiate() as CodeBlock
			slot.block.slot = slot # the codeblock will take care of reading everything from the slot
			add_child(slot.block)
	
	CodeBlockVisual.oscillation_phase = fmod(CodeBlockVisual.oscillation_phase + InteractionConfig.CODE_BLOCK_OSCILLATON_PHI * delta, TAU)

func add_spec(spec: CodeBlockSpec):
	_specs[spec.id] = spec
	return spec

func get_spec(id: StringName)->CodeBlockSpec:
	return _specs[id]

func add_family(family: CodeBlockFamily):
	_families[family.id] = family
	return family

func get_family(id: StringName)->CodeBlockFamily:
	return _families[id]

func add_slot(slot: CodeBlockSlot):
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
	_osc.send_code_command(group.head.slot.id, _compile_code_string(group), group.last_commit_id)

func _compile_code_string(group: CodeBlockGroup)->String:
	var ret: String = group.head.code_string
	if group.action != null:
		ret = ret + ";" + group.action.code_string
	for modifer in group.modifiers:
		ret = ret + ";" + modifer.code_string
	# print("Compiled code string: " + ret)
	return ret

func on_received_commit_executed(id: String, commit_id: int):
	var group := get_group(id)
	if group != null:
		group.on_commit_executed(commit_id)
