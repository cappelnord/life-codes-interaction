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
	_update_material()

func _update_material():
	var rgb = block.slot.spec.family.color
	background_material.set_shader_parameter("hsv", Vector3(rgb.h, rgb.s, rgb.v))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_size(size: Vector2):
	($"CodeBlockBackground" as Sprite2D).scale = size
	($"CodeBlockText" as Label).position = Vector2(InteractionConfig.CODE_BLOCK_PADDING_X, InteractionConfig.CODE_BLOCK_PADDING_Y)
