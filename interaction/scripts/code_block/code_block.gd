extends Node2D
class_name  CodeBlock

enum Type {
	SUBJECT,
	ACTION,
	# add ephemeral action here?
	MODIFIER
}

var slot: CodeBlockSlot
var arguments = {}
var display_string
var code_string
var text_box_size: Vector2
var grabbed = false

var head_of_group: bool = false
var group: CodeBlockGroup
var group_candidate: CodeBlockGroup
var is_rem_candidate = false

var _active_cursor: Cursor

@onready var _visual: CodeBlockVisual = $CodeBlockVisual
@onready var _collider: CodeBlockCollider = $CodeBlockCollider
@onready var _top_connection_collider: CodeBlockConnectionCollider = $TopConnectionCollider
@onready var _bottom_connection_collider: CodeBlockConnectionCollider = $BottomConnectionCollider
@onready var _label: Label = $"CodeBlockVisual/CodeBlockText"

# Called when the node enters the scene tree for the first time.
func _ready():
	position = slot.start_position
	
	_collider.block = self
	
	_collider.area_entered.connect(_on_connection_area_entered)
	_collider.area_exited.connect(_on_connection_area_exited)
	
	_top_connection_collider.block = self
	_bottom_connection_collider.block = self
	
	_visual.init_with_block(self)
	
	# copy arguments over from the slot - duplication is likely more manual than it needs to be
	for key in slot.arguments:
		arguments[key] = slot.arguments[key].duplicate()
	
	_update_strings()
	_update_sizes()
	
	if slot.spec.head_role():
		head_of_group = true
		group = CodeBlockGroup.new(self)

func _update_sizes():
	_visual.set_size(text_box_size)
	
	var collision_shape = RectangleShape2D.new()
	collision_shape.size = text_box_size
	_collider.collision_shape.set_shape(collision_shape)
	_collider.position = text_box_size * 0.5
	
	# for now deactivate the top connection collider
	_top_connection_collider.monitorable = false
	_top_connection_collider.monitoring = false
	
	var connection_collider_size = text_box_size * Vector2(1.0, 0.333333)
	
	var collision_shape_bottom = RectangleShape2D.new()
	collision_shape_bottom.size = connection_collider_size
	_bottom_connection_collider.collision_shape.set_shape(collision_shape_bottom)
	_bottom_connection_collider.position = connection_collider_size * 0.5 + Vector2(0, text_box_size.y * 0.666666)	

func _update_strings():
	# build the display_string and code_string and set it
	display_string = slot.display_string
	code_string = slot.spec.id
	
	# we should iterate over parameters and then see if we have one set; otherwise use default parameters
	# for now we only havew constant parameters/arguments
	for parameter in slot.spec.parameters:
		var value = parameter.default
		if parameter.id in arguments:
			value = arguments[parameter.id].value
		display_string = display_string + " " + str(value)
		code_string = code_string + "," + parameter.type_tag() + str(value)
	
		
	_label.add_theme_font_size_override("font_size", InteractionConfig.CODE_BLOCK_FONT_SIZE)
	_label.text = display_string
	text_box_size = _label.get_theme_font("font").get_string_size(display_string, HORIZONTAL_ALIGNMENT_LEFT, -1,  InteractionConfig.CODE_BLOCK_FONT_SIZE)
	text_box_size = text_box_size + Vector2(2 * InteractionConfig.CODE_BLOCK_PADDING_X, 2 * InteractionConfig.CODE_BLOCK_PADDING_Y)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move(new_position: Vector2, propage_to_group: bool=true):
	position = new_position
	if _visual.snapped: _visual.update_position_offset()
	if group != null and self == group.head and propage_to_group:
		group.update_positions()
	
func move_delta(delta: Vector2):
	if group != null and group.active_block_is_glued() and group.head != self:
		group.head.move(group.head.position + delta)
	else:
		move(position + delta)
	
func attempt_hover(cursor: Cursor):	
	if group != null and group.active_block != null: return false
	
	if _active_cursor == null:
		_active_cursor = cursor
		
		if group != null:
			group.active_block = self
			
		_update_visual_or_group_visual()
			
		return true
		
	return false

func release_hover(cursor: Cursor):
	if _active_cursor == cursor:
		_active_cursor = null
		
		if group != null:
			group.active_block = null # TODO: Check if this can create issues
		
		_update_visual_or_group_visual()

# TODO: do more thorough checks  if the block can actually be grabbed
func attempt_grab(cursor: Cursor):
	if grabbed: return false
	if cursor != _active_cursor:
		return false
	else:
		grabbed = true
		
		if group != null and not group.block_is_glued(self):
			is_rem_candidate = true
			group.set_rem_candidate(self)
			
		_update_visual_or_group_visual()
		_collider.set_collision_mask_value(InteractionConfig.COLLISION_LAYER_BOTTOM_CONNECTION, true)
		_move_to_front_or_group_to_front()
		return true
	
func release_grab(cursor: Cursor):
	# if we release while we are a candidate then we commit
	
	if is_rem_candidate:
		# if they are the same it will be dealt with in the group_candidate_comit
		# TODO: This seems to be a mess somehow
		if group != group_candidate:
			group.commit(null)
			group.active_block = null
			move_to_front()
			var old_group := group
			group = null
			old_group.update_visual()
			_update_visual_or_group_visual()
			
	if group_candidate != null:
		var success: bool = group_candidate.commit(self)
	
		if success:
			group = group_candidate
			group.move_all_to_front()
		
	group_candidate = null
	is_rem_candidate = false
	grabbed = false
	
	_collider.set_collision_mask_value(InteractionConfig.COLLISION_LAYER_BOTTOM_CONNECTION, false)
	
	_update_visual_or_group_visual()

func is_hovered():
	var group_hover = false
	if group != null:
		group_hover = group.active_block_is_glued()
	return _active_cursor != null or group_hover


func _on_connection_area_entered(collider: CodeBlockConnectionCollider):
	if collider.block == self: return false
	print("Attempt to connect: " + display_string + "->" + collider.block.display_string)
	if collider.block.can_connect(self):
		collider.block.group.set_add_candidate(self, collider.block)
	else:
		pass
	
func _on_connection_area_exited(collider: CodeBlockConnectionCollider):
	if collider.block == self: return
	if collider.block.group != null:
		collider.block.group.release_add_candidate(self, collider.block)

func can_connect(other: CodeBlock):
	# in case the other block has a head role we can never connect
	if other.slot.spec.head_role(): return false
	
	# in case the block is not yet part of a group it cannot connect
	if group == null: return false
	
	# check types
	if slot.spec.head_role() and not other.slot.spec.action_role(): return false
	if slot.spec.action_role() and not (other.slot.spec.action_role() or other.slot.spec.modifier_role()): return false
	if slot.spec.modifier_role() and not (other.slot.spec.action_role() or other.slot.spec.modifier_role()): return false
	
	# basic tests done, let's see what the group is thinking
	return group.can_connect(other, self)

func snap(snap_position: Vector2):
	_visual.snap(snap_position)

func unsnap():
	_visual.unsnap()

func _to_string():
	return "<" + slot.id + "/" + display_string + ">"

func resign():
	pass

func update_visual():
	_visual.update_material_and_zindex()
	
func _move_to_front_or_group_to_front():
	if group == null:
		move_to_front()
	else:
		group.move_all_to_front()

func _update_visual_or_group_visual():
	if group == null:
		_visual.update_material_and_zindex()
	else:
		group.update_visual()
