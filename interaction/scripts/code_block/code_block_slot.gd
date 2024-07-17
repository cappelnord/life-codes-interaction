extends Object
class_name CodeBlockSlot

var id: StringName
var display_string: String
var spec: CodeBlockSpec
var start_position: Vector2
# should be copied when CodeBlock is spawned
var arguments: Dictionary
var family: CodeBlockFamily
var behaviour: CodeBlockBehaviour
var context: String

var _should_respawn = true
var block: CodeBlock = null
var manager: CodeBlockManager

var deleted := false

# this has become a mess

# arguments: Array[CodeBlockArgument] = []
# family: CodeBlockFamily = null
# behaviour: CodeBlockBehaviour=null
# display_string: String = ""
# context: String = ""

func _init(spec: CodeBlockSpec, start_position: Vector2, id: StringName = &"", options: Variant = {}):

	if id == &"": id = StringName(str(spec.id) + "-" + InteractionHelpers.random_id())
		
	self.id = id
	self.spec = spec
	self.start_position = start_position

	self.family = options.get("family", spec.family)
	self.behaviour = options.get("behaviour", CodeBlockBehaviour.get_behaviour("default")) 
	self.context = options.get("context", "")
	self.display_string = options.get("display_string", spec.display_string)

	var arguments = options.get("arguments", [])

	self.arguments = {}
	for argument in arguments:
		self.arguments[argument.parameter.id] = argument	

func should_spawn() -> bool:
	return block == null and _should_respawn

func delete():
	_should_respawn = false
	deleted = true
	if block:
		block.delete()
