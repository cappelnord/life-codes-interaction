extends Object
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
	self.value = value

func duplicate() -> CodeBlockArgument:
	return CodeBlockArgument.new(parameter, type, value)
