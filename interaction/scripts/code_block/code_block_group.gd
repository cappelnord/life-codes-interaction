extends Object
class_name CodeBlockGroup

var family: CodeBlockFamily
var head: CodeBlock
var action: CodeBlock
var modifiers: Array[CodeBlock] = []
var active_block: CodeBlock
var _add_candidate: CodeBlock
var _rem_candidate: CodeBlock
var _candidate_target: CodeBlock

func _init(head: CodeBlock):
	self.head = head
	self.family = head.slot.family

func commit(new_block: CodeBlock)->bool:
	var success := false
	
	# shortcut in case we did not change anything
	# TODO: we must also check that it is the same position
	"""
	if _rem_candidate == new_block:
		_add_candidate = null
		_candidate_target = null
		_rem_candidate = null
		update_positions()
		return true
	"""
	
	if _rem_candidate != null:
		modifiers = _updated_modifiers_array_rem(_rem_candidate)
		_rem_candidate = null
		success = true
	
	if new_block != null and new_block == _add_candidate:
		if _candidate_target == head:
			if action != null:
				action.resign()
			action = _add_candidate
		else:
			modifiers = _updated_modifiers_array(_add_candidate, _candidate_target)
		
		_add_candidate = null
		_candidate_target = null
		
		success = true
		
	if success:
		head.slot.manager.on_group_comitted.call_deferred(self)
	
	update_positions()

	return success

func update_visual():
	for block in all_members():
		block.update_visual()

func update_positions():
	var pos := head.position
	for member in all_members():
		member.unsnap()
		member.move(pos, false)
		pos = pos + Vector2(0, member.text_box_size.y)

func can_connect(new_block: CodeBlock, target_block: CodeBlock):
	# special rule to allow moving blocks within the hierarchy
	if active_block != null and active_block != new_block: return false
	
	# these must be dealt with in some way but not now
	if new_block == target_block: return false

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

func set_rem_candidate(block: CodeBlock):
	_rem_candidate = block
	print("Remove Candidate: " + str(block))

func release_add_candidate(block: CodeBlock, target_block: CodeBlock):
	if _add_candidate == null: return
	
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
		if(not (old_block == block)):
			ret.append(old_block)
		if(old_block == target_block):
			ret.append(block)
	return ret

func _updated_modifiers_array_rem(block: CodeBlock)->Array[CodeBlock]:
	var ret: Array[CodeBlock] = []
	for old_block in modifiers:
		if old_block != block:
			ret.append(old_block)
	return ret

func block_is_glued(block: CodeBlock)->bool:
	return block == head or block == action

func active_block_is_glued():
	if active_block == null: return false
	return block_is_glued(active_block)

func move_all_to_front():
	for member in all_members():
		member.move_to_front()
