extends Node2D
class_name CodeBlockVisual

static var oscillation_phase: float = 0

static var defaultFont = preload("res://interaction/fonts/SourceCodePro-Medium.ttf")
static var actionFont = preload("res://interaction/fonts/SourceCodePro-Bold.ttf")
static var subjectFont = preload("res://interaction/fonts/SourceCodePro-Black.ttf")

var block: CodeBlock
var background_material: Material
var snapped := false
var muted := false
var superseded := false

var _snap_position: Vector2
var _flash_ramp: float = 0.0
var _current_font = null

@onready var _shadow := ($CodeBlockShadow as Sprite2D)
@onready var _code_block_text := ($CodeBlockText as Label)


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = Config.Z_INDEX_CODE_BLOCK

func _switch_font(font):
	if _current_font != font:
		_code_block_text.set("theme_override_fonts/font", font)
		_current_font = font

func init_with_block(block: CodeBlock):
	self.block = block
	var background = ($CodeBlockBackground as Sprite2D)
	background_material = background.material.duplicate()
	background.material = background_material
	
	if block.slot.spec.head_role():
		_switch_font(subjectFont)
	elif block.slot.spec.action_role() and block.group == null:
		_switch_font(actionFont)
	else:
		_switch_font(defaultFont)
	
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
	
	# wowowieeee 
	
	if block.grabbed or (block.group != null and block.group.head != null and block.group.head.grabbed) or (block.group != null and block.group.action != null and block.group.action.grabbed):
		rgb_add = Vector3(0.25, 0.25, 0.25)
		z_index = Config.Z_INDEX_GRABBED_OR_SNAPPED_CODE_BLOCK
	elif snapped or (block.group != null and block.group.active_block != null and block.group.active_block.grabbed):
		rgb_add = Vector3(0.15, 0.15, 0.15)
		z_index = Config.Z_INDEX_GRABBED_OR_SNAPPED_CODE_BLOCK
	elif block.is_hovered():
		rgb_add = Vector3(0.1, 0.1, 0.1)
		z_index = Config.Z_INDEX_HOVERED_CODE_BLOCK
	else:
		z_index = Config.Z_INDEX_CODE_BLOCK
		
	if block.group != null and block.group.pending_action:
		hsv_mod = hsv_mod * Vector3(1, 1, 1.0 - ((sin(oscillation_phase) + 1.0) * 0.1))
		
	if _flash_ramp > 0:
		var flash_value := _flash_ramp * Config.code_blocks_flash_intensity
		rgb_add = rgb_add + Vector3(flash_value, flash_value, flash_value)
	
	var dont_apply_effects = (block.grabbed or snapped)
	
	# apply group effects
	if muted and not dont_apply_effects:
		hsv_mod.y = hsv_mod.y * 0.8
		hsv_mod.z = hsv_mod.z * 0.75
		
	var block_connected = block.group != null
	
	var text_color := Color.WHITE
	
	if not block_connected:
		pass
	#	text_color = Color(0.9, 0.9, 0.9, 0.9)
	elif (superseded and not dont_apply_effects):
		text_color = Color(0.7, 0.7, 0.7, 0.5)
	
	_code_block_text.modulate = text_color
	
	background_material.set_shader_parameter("hsv", Vector3(rgb.h, rgb.s, rgb.v) * hsv_mod)
	background_material.set_shader_parameter("rgb_add", rgb_add)
		

# Called every frame. 'delta' is the elapsed time sinc e the previous frame.
func _process(delta):
	if (block.group != null and block.group.pending_action) or _flash_ramp > 0:
		if _flash_ramp > 0:
			_flash_ramp -= Config.code_blocks_flash_ramp_speed * delta;
			if _flash_ramp < 0: _flash_ramp = 0
		update_material_and_zindex()

func set_size(size: Vector2):
	($CodeBlockBackground as Sprite2D).scale = size
	_code_block_text.position = Vector2(Config.code_blocks_padding_x, Config.code_blocks_padding_y)
	
	var oversize := Vector2(1.5, 1.25) * 1.05
	var shadow_size := size * oversize
	
	_shadow.position = (size - shadow_size) * 0.5
	_shadow.scale = shadow_size / Vector2(128, 64)

func snap(position: Vector2):
	_snap_position = position
	snapped = true
	update_position_offset()
	update_material_and_zindex()

func unsnap():
	snapped = false
	update_position_offset()
	update_material_and_zindex()

func flash(strength: float=1):
	_flash_ramp = strength

func update_fade(strength: float=1):
	strength = max(0.0, strength)
	modulate = Color(1.0*strength, 1.0*strength, 1.0*strength, strength)
	strength = pow(strength, 6)
	_shadow.self_modulate = Color(strength, strength, strength, strength)
