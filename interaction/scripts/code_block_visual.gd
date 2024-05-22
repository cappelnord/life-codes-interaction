extends Node2D
class_name CodeBlockVisual

var block: CodeBlock
var background_material: Material


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init_with_block(block: CodeBlock):
	self.block = block
	var background = ($"CodeBlockBackground" as Sprite2D)
	background_material = background.material.duplicate()
	background.material = background_material
	update_material()

func update_material():
	var rgb = block.slot.family.color
	var hsv_mod = Vector3(1, 1, 1)
	var rgb_add = Vector3(0, 0, 0)
	
	if block.is_hovered():
		rgb_add = Vector3(0.1, 0.1, 0.1)
	if block.grabbed:
		rgb_add = Vector3(0.2, 0.2, 0.2)
	
	background_material.set_shader_parameter("hsv", Vector3(rgb.h, rgb.s, rgb.v) * hsv_mod)
	background_material.set_shader_parameter("rgb_add", rgb_add)
		

# Called every frame. 'delta' is the elapsed time sinc e the previous frame.
func _process(delta):
	pass

func set_size(size: Vector2):
	($"CodeBlockBackground" as Sprite2D).scale = size
	($"CodeBlockText" as Label).position = Vector2(InteractionConfig.CODE_BLOCK_PADDING_X, InteractionConfig.CODE_BLOCK_PADDING_Y)

