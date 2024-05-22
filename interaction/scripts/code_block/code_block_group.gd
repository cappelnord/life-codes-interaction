extends Object
class_name CodeBlockGroup

var family: CodeBlockFamily
var head: CodeBlock
var action: CodeBlock
var modifiers: Array[CodeBlock] = []
var _add_candidate: CodeBlock
var _candidate_target: CodeBlock

func _init(head: CodeBlock):
	self.head = head
	self.family = head.slot.family

func can_connect(new_block: CodeBlock, target_block: CodeBlock):
	# these must be dealt with in some way but not now
	if new_block == target_block: return false
	if new_block.group == self: return false

	# check if the family is compatible
	if not new_block.slot.family.is_compatible(family): return false
	
	return true
	
func set_add_candidate(block: CodeBlock, target_block: CodeBlock):
	_add_candidate = block
	_candidate_target = target_block
	
	block.group_candidate = self
	
	var snap_position := head.position
	
	for member in all_members_candidate():
		member.snap(snap_position)
		snap_position = snap_position + Vector2(0, member.text_box_size.y)
	
	print(all_members_candidate())

func release_add_candidate(block: CodeBlock, target_block: CodeBlock):
	if(block == _add_candidate):
		_add_candidate = null
		_candidate_target = null
	
	block.group_candidate = null
	
	block.unsnap()
	for member in all_members():
		member.unsnap()
	
	print(all_members_candidate())

func all_members()->Array[CodeBlock]:
	var ret: Array[CodeBlock] = []
	ret.append(head)
	if action != null: ret.append(action)
	ret.append_array(modifiers)
	return ret

func all_members_candidate()->Array[CodeBlock]:
	if _add_candidate == null: return all_members()
	
	var ret: Array[CodeBlock] = []
	ret.append(head)
	if _add_candidate.slot.spec.action_role():
		ret.append(_add_candidate)
	else:
		if action != null: ret.append(action)
	
	ret.append_array(_updated_modifiers_array(_add_candidate, _candidate_target))
	
	return ret
	
func _updated_modifiers_array(block: CodeBlock, target_block: CodeBlock)->Array[CodeBlock]:
	var ret: Array[CodeBlock] = []
	if target_block.slot.spec.action_role(): ret.append(block)
	for old_block in modifiers:
		ret.append(old_block)
		if(old_block == target_block):
			ret.append(block)
	return ret
