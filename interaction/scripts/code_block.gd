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

var _visual: CodeBlockVisual

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = InteractionConfig.Z_INDEX_CODE_BLOCK
	position = slot.start_position
	
	_visual = ($"CodeBlockVisual" as CodeBlockVisual)
	_visual.init_with_block(self)
	
	# copy arguments over from the slot - duplication is likely more manual than it needs to be
	for key in slot.arguments:
		arguments[key] = slot.arguments[key].duplicate()
	
	_update_strings()

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
		code_string = code_string + "," + str(value)
	
	var label = ($"CodeBlockVisual/CodeBlockText" as Label)
	label.add_theme_font_size_override("font_size", InteractionConfig.CODE_BLOCK_FONT_SIZE)
	label.text = display_string
	text_box_size = label.get_theme_font("font").get_string_size(display_string, HORIZONTAL_ALIGNMENT_LEFT, -1,  InteractionConfig.CODE_BLOCK_FONT_SIZE)
	text_box_size = text_box_size + Vector2(2 * InteractionConfig.CODE_BLOCK_PADDING_X, 2 * InteractionConfig.CODE_BLOCK_PADDING_Y)
	
	_visual.set_size(text_box_size)
	
	# we apply it here to CodeBlockVisual which will deal with all the sizing of visual elements
	# TODO: scale the collider


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move(new_position: Vector2):
	position = new_position
