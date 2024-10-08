extends Node2D
class_name CodeBlock

enum Type {
	SUBJECT,
	ACTION,
	# add ephemeral action here?
	MODIFIER
}

var slot: CodeBlockSlot
var behaviour_host := CodeBlockBehaviourHost.new()
var behaviour_activity_ramp := 1.0
var arguments = {}
var display_string
var code_string
var text_box_size: Vector2
var grabbed = false
var subpixel_position: Vector2
var displacement_vector := Vector2.ZERO
var displacement_speed := Vector2.ZERO

var head_of_group: bool = false
var group: CodeBlockGroup
var group_candidate: CodeBlockGroup
var is_rem_candidate = false

var _active_cursor: Cursor

var _marked_for_despawn := false
var despawn_fade_time = 0.0
var _despawn_timer = 0.0
var despawning := false

var deleted := false

var _last_sent_position: Vector2

@onready var visual: CodeBlockVisual = $CodeBlockVisual

@onready var _collider: CodeBlockCollider = $CodeBlockCollider
@onready var _top_connection_collider: CodeBlockConnectionCollider = $TopConnectionCollider
@onready var _bottom_connection_collider: CodeBlockConnectionCollider = $BottomConnectionCollider
@onready var _label: Label = $"CodeBlockVisual/CodeBlockText"

# Called when the node enters the scene tree for the first time.
func _ready():
		
	position = slot.start_position
	subpixel_position = position
	
	var behaviour_instance = slot.behaviour.clone()
	behaviour_instance.initialize(self, behaviour_host)
	behaviour_host.replace_behaviour(behaviour_instance)
	
	_collider.block = self
	
	_collider.area_entered.connect(_on_connection_area_entered)
	_collider.area_exited.connect(_on_connection_area_exited)
	
	_top_connection_collider.block = self
	_bottom_connection_collider.block = self
	
	
	# copy arguments over from the slot - duplication is likely more manual than it needs to be
	for key in slot.arguments:
		arguments[key] = slot.arguments[key].duplicate()
		
	if slot.spec.head_role():
		head_of_group = true
		group = CodeBlockGroup.new(self)

	visual.init_with_block(self)
	
	_update_strings()
	# always call _update_sizes() after _update_strings()
	_update_sizes()

func _update_sizes():
	visual.set_size(text_box_size)
	
	var collision_shape = RectangleShape2D.new()
	collision_shape.size = text_box_size
	_collider.collision_shape.set_shape(collision_shape)
	_collider.position = text_box_size * 0.5
	
	# for now deactivate the top connection collider
	_top_connection_collider.monitorable = false
	_top_connection_collider.monitoring = false
	
	var connection_collider_size = text_box_size * Vector2(1.0, 0.3333333)
	
	var collision_shape_bottom = RectangleShape2D.new()
	collision_shape_bottom.size = connection_collider_size
	_bottom_connection_collider.collision_shape.set_shape(collision_shape_bottom)
	_bottom_connection_collider.position = connection_collider_size * 0.5 + Vector2(0, text_box_size.y * 0.6666666)	

func _update_strings():
	var alt_decoration := true
	
	# build the display_string and code_string and set it
	display_string = slot.display_string
	code_string = slot.spec.code_string + "?" + slot.id
	
	var do_decorate = alt_decoration and not slot.spec.head_role() and not slot.spec.effects.dont_decorate
	
	if do_decorate:
		display_string = "." + display_string + "("
	
	# we should iterate over parameters and then see if we have one set; otherwise use default parameters
	# for now we only havew constant parameters/arguments
	
	var first_display_parameter := true
	
	for parameter in slot.spec.parameters:
		var value = parameter.default
		var display := false
		if parameter.id in arguments:
			var argument = arguments[parameter.id]
			value = argument.value
			display = argument.display()
		
		if display:
			if not alt_decoration:
				display_string = display_string + " " + str(value)
			else:
				var v = str(value)
				# if value is String:
				#	v = "\"" + v + "\""
				if not first_display_parameter:
					display_string = display_string + ", "
				display_string = display_string + v
			
			code_string = code_string + "," + parameter.type_tag() + str(value)
			first_display_parameter = false
	
	if do_decorate:
		display_string = display_string + ")"
	
	var type_modifier = 1.0
	var type_padding_modifier = 1.0
		
	var font_size = Config.code_blocks_font_size
	
	if slot.spec.modifier_role() or slot.spec.action_role():
		type_modifier = 0.8
		type_padding_modifier = 0.9
		
	_label.add_theme_font_size_override("font_size", floor(font_size * type_modifier))
	_label.text = display_string
	text_box_size = _label.get_theme_font("font").get_string_size(display_string, HORIZONTAL_ALIGNMENT_LEFT, -1,  font_size * type_modifier)
	text_box_size = text_box_size + Vector2(2 * floor(Config.code_blocks_padding_x * type_padding_modifier), 2 * floor(Config.code_blocks_padding_y * type_padding_modifier))

func _physics_process(delta):
	_attempt_despawn()
	
	if despawning:
		_process_despwaning(delta)
	
	if despawning or deleted: return
	
	if is_bound_or_active():
		behaviour_activity_ramp = 0	
	else:
		behaviour_activity_ramp = lerp(behaviour_activity_ramp, 1.0, delta * 0.1)
	
	var movement := behaviour_host.get_delta_movement(self, delta)
	# we do not call move_delta and move directly as otherwise we
	# got into a state where things are not higlighted properly .. it is important
	# that this only happens when the block is not active, snapped or part of a group
	subpixel_position = subpixel_position + (movement * behaviour_activity_ramp)
	
	# DISPLACEMENT IS SUCH A MESS ...
	
	var do_displace = true
	if group != null:
		do_displace = group.user_can_hover()
	
	var did_displace = false
	if not (displacement_speed == Vector2.ZERO and displacement_vector == Vector2.ZERO) and do_displace:
		subpixel_position = subpixel_position + _process_displacement(delta)
		did_displace = true
	
	
	if not behaviour_host.ignore_interaction_boundary():
		if group == null or head_of_group:
			subpixel_position.x = clamp(subpixel_position.x , Config.app_interaction_boundary_topleft.x, Config.app_interaction_boundary_bottomright.x - text_box_size.x)
			subpixel_position.y = clamp(subpixel_position.y, Config.app_interaction_boundary_topleft.y, Config.app_interaction_boundary_bottomright.y - text_box_size.y)
	
	if Config.code_blocks_quantize_position:
		position = Vector2(round(subpixel_position.x), round(subpixel_position.y))
	else:
		position = subpixel_position
	
	if head_of_group and did_displace:
		group.update_subpixel_positions()

func _process_displacement(delta):
	# see that we kill momentum if we come while the block is grabbed
	if grabbed:
		displacement_speed = Vector2.ZERO
		displacement_vector = Vector2.ZERO
		return Vector2.ZERO
	
	displacement_speed = (displacement_speed * 0.98) + (displacement_vector * 0.02)
	displacement_vector = Vector2.ZERO
	if displacement_speed.length() > 0.00000000001:
		var movement = displacement_speed * delta
		return movement
	else:
		displacement_speed = Vector2.ZERO
		return Vector2.ZERO
		

func _process(delta):
	
	# send position of the head (if context is known)
	if head_of_group and Config.osc_send_head_position and slot.context != "":
		if _last_sent_position != position:
			slot.manager.on_context_data_update(slot.context, {"headPosX": position.x / Config.app_render_width, "headPosY": position.y / Config.app_render_height})
			_last_sent_position = position

func move(new_position: Vector2, propagate_to_group: bool=true):
	
	if group == null or head_of_group:
		new_position.x = clamp(new_position.x , Config.app_interaction_boundary_topleft.x, Config.app_interaction_boundary_bottomright.x - text_box_size.x)
		new_position.y = clamp(new_position.y, Config.app_interaction_boundary_topleft.y, Config.app_interaction_boundary_bottomright.y - text_box_size.y)
	
	subpixel_position = new_position
	
	if Config.code_blocks_quantize_position:
		position = Vector2(round(subpixel_position.x), round(subpixel_position.y))
	else:
		position = subpixel_position
		
	if visual.snapped: visual.update_position_offset()
	if group != null and self == group.head and propagate_to_group:
		group.update_positions()
	
func move_delta(delta: Vector2):
	if group != null and group.active_block_is_glued() and group.head != self and not group.despawning:
		group.head.move(group.head.subpixel_position + delta)
	else:
		move(subpixel_position + delta)

# TODO: Maybe should not hover on a group that is currently manipulated on	
func attempt_hover(cursor: Cursor):	
	if despawning or deleted: return false
	if group != null and not group.user_can_hover(): return false
	
	# should keep multi user scenario safe
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

# TODO should not be able to grab from a group that is currently manipulated.
func attempt_grab(cursor: Cursor):
	if despawning or deleted: return false
	if grabbed: return false
	# should keep multi user scenario safe
	if cursor != _active_cursor:
		return false
	else:
		grabbed = true
		
		if group != null and not group.block_is_glued(self):
			is_rem_candidate = true
			group.set_rem_candidate(self)
			
		_update_visual_or_group_visual()
		_collider.set_collision_mask_value(Config.COLLISION_LAYER_BOTTOM_CONNECTION, true)
		_move_to_front_or_group_to_front()
		return true
	
func release_grab(cursor: Cursor):
	if cursor != _active_cursor: return 
	
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
			cursor.notify_connect_block_successful()
			group = group_candidate
			group.move_all_to_front()
		
	group_candidate = null
	is_rem_candidate = false
	grabbed = false
	
	# fix for the "can take play blocks away" thingy
	release_hover(cursor)
	attempt_hover(cursor)
	
	_collider.set_collision_mask_value(Config.COLLISION_LAYER_BOTTOM_CONNECTION, false)
	
	_update_visual_or_group_visual()

func is_hovered():
	var group_hover := false
	if group != null:
		group_hover = group.active_block_is_glued()
	return _active_cursor != null or group_hover

## Checks if the code block is bound to a group.
func is_bound_or_active():
	return _active_cursor != null or (group != null and group.has_action()) or visual.snapped

func _on_connection_area_entered(collider: CodeBlockConnectionCollider):
	if collider.block == self: return false
	if collider.block == null: return false
	if collider.block.despawning: return false
	if collider.block.deleted: return false
	if self.despawning: return false
	if self.deleted: return false
	
	# this crash happened every now and then .. I hope this will not give us any disadvantages.
	# my assumption is that the collision is queued up and the _active_cursor gets taken away
	# at some other point before. Added print here to see if other things are not working out.
	if _active_cursor == null:
		if OS.is_debug_build() and Config.debug_verbose:
			print("_active_cursor was null in _on_connection_area_entered - did other strange things happen?")
		return false
	
	# print("Attempt to connect: " + display_string + "->" + collider.block.display_string)
	if collider.block.can_connect(self):
		_active_cursor.notify_snap()
		collider.block.group.set_add_candidate(self, collider.block)
		return true
	else:
		return false
	
func _on_connection_area_exited(collider: CodeBlockConnectionCollider):
	if collider.block == self: return false
	if collider.block == null: return false
	if collider.block.despawning: return false
	if collider.block.deleted: return false
	if self.despawning: return false
	if self.deleted: return false

	if _active_cursor == null:
		if OS.is_debug_build() and Config.debug_verbose:
			print("_active_cursor was null in _on_connection_area_exited - did other strange things happen?")
		return false	

	if collider.block.group != null:
		collider.block.group.release_add_candidate(self, collider.block)
		_attempt_reconnect()
		

func can_connect(other: CodeBlock):
	if despawning or deleted:
		return false
	
	# in case the other block has a head role we can never connect
	if other.slot.spec.head_role(): return false
	
	# in case we are moving an action role that already is part of a group this can never connect
	if other.slot.spec.action_role() and other.group != null: return false
	
	# in case the block is not yet part of a group it cannot connect
	if group == null: return false
	
	# check types
	if slot.spec.head_role() and not other.slot.spec.action_role(): return false
	if slot.spec.action_role() and not (other.slot.spec.action_role() or other.slot.spec.modifier_role()): return false
	if slot.spec.modifier_role() and not (other.slot.spec.action_role() or other.slot.spec.modifier_role()): return false
	
	# basic tests done, let's see what the group is thinking
	return group.can_connect(other, self)


func _to_string():
	return "<" + slot.id + "/" + display_string + ">"

func queue_despawn(despawn_fade_time: float):
	if despawning or deleted: return
	_marked_for_despawn = true
	self.despawn_fade_time = despawn_fade_time

func _attempt_despawn():
	if _marked_for_despawn and not despawning:
		
		# if the block is free then we can proceed with despawning
		if group_candidate:
			group_candidate.release_add_candidate(self, null)
		
		if group == null:
			do_despawn()
		elif head_of_group:
			for block in group.all_members:
				block.despawn_fade_time = despawn_fade_time
				block.do_despawn()
			group.despawning = true
				

func do_despawn():
	despawning = true
	if _active_cursor:
		_active_cursor.cleanup()
	_despawn_timer = despawn_fade_time

func _process_despwaning(delta: float):
	_despawn_timer = _despawn_timer - delta
	visual.update_fade(_despawn_timer / despawn_fade_time)
	if _despawn_timer < 0:
		delete()

# this is radical and does not check/care if the block is part of a group ...
# ... it is also the last step of a more soft resign/dismiss process
func delete(hard: bool=false):
	deleted = true
	
	if _active_cursor:
		_active_cursor.cleanup()
	
	if group:
		# group.unlink_on_delete(self, hard)
		group = null
		head_of_group = false
		
	queue_free()
	
	if OS.is_debug_build() and Config.debug_verbose:
		print("Delete Block: " + slot.id)
	
	slot.block_was_deleted()
	
func _move_to_front_or_group_to_front():
	if group == null:
		move_to_front()
	else:
		group.move_all_to_front()

func _clear_group_effects():
	visual.muted = false
	visual.superseded = false

func _update_visual_or_group_visual():
	if group == null:
		_clear_group_effects()
		visual.update_material_and_zindex()
	else:
		group.update_visual()

func _attempt_reconnect():
	var areas = _collider.get_overlapping_areas()
	for area in areas:
		if _on_connection_area_entered(area): return 
