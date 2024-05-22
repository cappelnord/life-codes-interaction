extends Object
class_name CodeBlockSpec

var id: StringName
var display_string: String
var type: CodeBlock.Type
var family: CodeBlockFamily
var parameters: Array

func _init(id: StringName, display_string: String, type: CodeBlock.Type, family: CodeBlockFamily, parameters: Array):
	self.id = id
	self.display_string = display_string
	self.type = type
	self.family = family
	self.parameters = parameters

func get_parameter(id: StringName):
	for parameter in parameters:
		if parameter.id == id: return parameter
	return null

func head_role() -> bool:
	return type == CodeBlock.Type.SUBJECT

func action_role() -> bool:
	return type == CodeBlock.Type.ACTION
	
func modifier_role() -> bool:
	return type == CodeBlock.Type.MODIFIER
