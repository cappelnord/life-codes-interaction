extends Object
class_name CodeBlockSlot

var id: StringName
var display_string: String
var spec: CodeBlockSpec
var start_position: Vector2
# should be copied when CodeBlock is spawned
var arguments: Dictionary

var _should_respawn = true
var block: CodeBlock = null

func _init(spec: CodeBlockSpec, start_position: Vector2, arguments: Array = [], id: StringName = &"", display_string: String = ""):
	if display_string == "": display_string = spec.display_string
	# TODO: check if this is actually a memory leak
	if id == &"": id = StringName(str(spec.id) + "-" + str(str(randf_range(0.0, 1.0)).hash()))
	
	self.id = id
	self.display_string = display_string
	self.spec = spec
	self.start_position = start_position
	self.arguments = {}
	for argument in arguments:
		self.arguments[argument.parameter.id] = argument	

func should_spawn() -> bool:
	return block == null and _should_respawn
