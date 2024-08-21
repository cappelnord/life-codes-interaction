extends RefCounted
class_name CodeBlockGroup

var family: CodeBlockFamily
var head: CodeBlock
var action: CodeBlock
var modifiers: Array[CodeBlock] = []
var active_block: CodeBlock
var last_command_id: String
var all_members: Array[CodeBlock] = []
var pending_action: bool = false

var _add_candidate: CodeBlock
var _rem_candidate: CodeBlock
var _candidate_target: CodeBlock

func _init(head: CodeBlock):
	self.head = head
	self.family = head.slot.family
	_update_all_members()

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
		_update_all_members()
		last_command_id = str(InteractionHelpers.random_int32_id())
		head.slot.manager.on_group_comitted.call_deferred(self)
		
		if head.slot.family.quant:
			pending_action = true
		flash(1)
	
	update_positions()

	return success

func _apply_group_effects():
	# if any of the blocks have the mutes flag all should be muted
	var muted = false
	for block in all_members:
		muted = muted || block.slot.spec.effects.mutes
	for block in all_members:
		block.visual.muted = muted
		
	# start from the bottom, track which values are set and then 
	# mark any block that tracks effects and does not have any
	# effect anymore as superseded.
	var values_set = Dictionary()
	for i in range(all_members.size() - 1, -1, -1):
		var block := all_members[i]
		var effects := block.slot.spec.effects
		
		if not effects.track_effects: continue
		
		# we first check and then set, so that a block does
		# not supersede itself!
		
		var superseded = true
		for value in effects.modifies_values:
			if not values_set.has(value):
				superseded = false
		for value in effects.sets_values:
			if not values_set.has(value):
				superseded = false
		
		
		block.visual.superseded = superseded
		
		# mark all values
		for value in effects.sets_values:
			values_set[value] = true

func update_visual():
	_apply_group_effects()
	for block in all_members:
		block.visual.update_material_and_zindex()

func flash(strength: float=1):
	for block in all_members:
		block.visual.flash(strength)

func update_positions():
	var pos := head.position
	for member in all_members:
		member.visual.unsnap()
		member.move(pos, false)
		pos = pos + Vector2(0, member.text_box_size.y)

func can_connect(new_block: CodeBlock, target_block: CodeBlock):
	# special rule to allow moving blocks within the hierarchy
	if active_block != null and active_block != new_block: return false
	
	# if we already have an action we don't want another one
	# (this might change later, but then we also need to deal with it better!)
	if action != null and new_block.slot.spec.action_role(): return false
	
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
		member.visual.snap(snap_position)
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
	
	block.visual.unsnap()
	for member in all_members:
		member.visual.unsnap()
	
	print(all_members_candidate())

func all_members_candidate()->Array[CodeBlock]:
	if _add_candidate == null: return all_members
	
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

func _update_all_members():
	all_members.clear()
	all_members.append(head)
	if action != null: all_members.append(action)
	all_members.append_array(modifiers)

func block_is_glued(block: CodeBlock)->bool:
	return block == head or block == action

func active_block_is_glued():
	if active_block == null: return false
	return block_is_glued(active_block)

func move_all_to_front():
	for member in all_members:
		member.move_to_front()

func has_action()->bool:
	return action != null

func unlink_on_delete(block: CodeBlock, hard: bool):
	if OS.is_debug_build() and Config.debug_verbose:
		print("Block " +  block.slot.id + " had to be unlinked from group on delete ...")
	
	
	if head == block:
		head = null
	if action == block:
		action = null
	
	var mods: Array[CodeBlock] = []
	
	for mod in modifiers:
		if mod != block:
			mods.append(block)
	
	modifiers = mods
	
	_update_all_members()
	
	# this should only happen if all members of the group are despawning (or dead)
	if OS.is_debug_build():
		var clean := true
		if head != null:
			clean = clean and head.despawning
		if action != null:
			clean = clean and action.despawning
		for mod in modifiers:
			if mod != null:
				clean = clean and mod.despawning
		
		if(not (clean or hard)):
			print("Group with mixed despawning states ...")
		# if this trips over there were blocks in the group that were not despawning
		# .. reactivate later!
		# assert(clean or hard)
	
	

func on_command_feedback(command_id: String):
	print("on_command_feedback")
	if command_id == last_command_id:
		pending_action = false
		flash(0.75)
		update_visual()
