extends RefCounted
class_name CodeBlockArgument

enum Type {
	CONSTANT
}

var parameter: CodeBlockParameter
var value
var type: Type

func _init(parameter: CodeBlockParameter, type: Type, value):
	self.parameter = parameter
	self.type = type
	
	# make sure that we actually store an integer here
	if parameter.type == CodeBlockParameter.Type.INTEGER:
		self.value = int(value)
	else:
		self.value = value

func duplicate() -> CodeBlockArgument:
	return CodeBlockArgument.new(parameter, type, value)

func display() -> bool:
	return value != parameter.hide
