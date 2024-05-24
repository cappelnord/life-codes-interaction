extends Object
class_name CodeBlockSlot

var id: StringName
var display_string: String
var spec: CodeBlockSpec
var start_position: Vector2
# should be copied when CodeBlock is spawned
var arguments: Dictionary
var family: CodeBlockFamily

var _should_respawn = true
var block: CodeBlock = null
var manager: CodeBlockManager

func _init(spec: CodeBlockSpec, start_position: Vector2, arguments: Array[CodeBlockArgument] = [], family: CodeBlockFamily = null, id: StringName = &"", display_string: String = ""):
	if display_string == "": display_string = spec.display_string
	# TODO: check if this is actually a memory leak
	if id == &"": id = StringName(str(spec.id) + "-" + InteractionHelpers.random_id())
	
	if family == null: family = spec.family
	
	self.id = id
	self.display_string = display_string
	self.spec = spec
	self.start_position = start_position
	self.arguments = {}
	self.family = family
	for argument in arguments:
		self.arguments[argument.parameter.id] = argument	

func should_spawn() -> bool:
	return block == null and _should_respawn
