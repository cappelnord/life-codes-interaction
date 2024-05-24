extends Object
class_name CodeBlockSpec

var id: StringName
var display_string: String
var type: CodeBlock.Type
var family: CodeBlockFamily
var parameters: Array[CodeBlockParameter]
var quant: bool

func _init(id: StringName, display_string: String, type: CodeBlock.Type, family: CodeBlockFamily, parameters: Array[CodeBlockParameter], quant:bool=false):
	self.id = id
	self.display_string = display_string
	self.type = type
	self.family = family
	self.parameters = parameters
	self.quant = quant

func get_parameter(id: StringName)->CodeBlockParameter:
	for parameter in parameters:
		if parameter.id == id: return parameter
	return null

func head_role() -> bool:
	return type == CodeBlock.Type.SUBJECT

func action_role() -> bool:
	return type == CodeBlock.Type.ACTION
	
func modifier_role() -> bool:
	return type == CodeBlock.Type.MODIFIER
