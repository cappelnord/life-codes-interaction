extends Node2D
class_name CodeBlockVisual

var block: CodeBlock
var background_material: Material
var snapped = false
var _snap_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = InteractionConfig.Z_INDEX_CODE_BLOCK

func init_with_block(block: CodeBlock):
	self.block = block
	var background = ($CodeBlockBackground as Sprite2D)
	background_material = background.material.duplicate()
	background.material = background_material
	update_material_and_zindex()

func update_position_offset():
	if not snapped:
		position = Vector2.ZERO
	else:
		position = _snap_position - block.position

func update_material_and_zindex():
	var rgb: Color 
	if block.group_candidate != null: 
		rgb = block.group_candidate.family.color
	elif block.group != null and not block.is_rem_candidate:
		rgb = block.group.family.color
	else:
		rgb = block.slot.family.color
		
	var hsv_mod := Vector3(1, 1, 1)
	var rgb_add := Vector3(0, 0, 0)
	
	if block.is_hovered():
		rgb_add = Vector3(0.1, 0.1, 0.1)
		z_index = InteractionConfig.Z_INDEX_HOVERED_CODE_BLOCK
	if block.grabbed or snapped or (block.group != null and block.group.active_block != null and block.group.active_block.grabbed):
		rgb_add = Vector3(0.15, 0.15, 0.15)
		z_index = InteractionConfig.Z_INDEX_GRABBED_OR_SNAPPED_CODE_BLOCK
	else:
		z_index = InteractionConfig.Z_INDEX_CODE_BLOCK
	
	background_material.set_shader_parameter("hsv", Vector3(rgb.h, rgb.s, rgb.v) * hsv_mod)
	background_material.set_shader_parameter("rgb_add", rgb_add)
		

# Called every frame. 'delta' is the elapsed time sinc e the previous frame.
func _process(delta):
	pass

func set_size(size: Vector2):
	($CodeBlockBackground as Sprite2D).scale = size
	($CodeBlockText as Label).position = Vector2(InteractionConfig.CODE_BLOCK_PADDING_X, InteractionConfig.CODE_BLOCK_PADDING_Y)
	
	var oversize := Vector2(1.5, 1.25) * 1.05
	var shadow_size := size * oversize
	
	($CodeBlockShadow as Sprite2D).position = (size - shadow_size) * 0.5
	($CodeBlockShadow as Sprite2D).scale = shadow_size / Vector2(128, 64)

func snap(position: Vector2):
	_snap_position = position
	snapped = true
	update_position_offset()
	update_material_and_zindex()

func unsnap():
	snapped = false
	update_position_offset()
	update_material_and_zindex()
