extends Object
class_name CodeBlockSpec

var id: StringName
var code_string: String
var display_string: String
var type: CodeBlock.Type
var family: CodeBlockFamily
var parameters: Array[CodeBlockParameter]

func _init(id: StringName, code_string: String, display_string: String, type: CodeBlock.Type, family: CodeBlockFamily, parameters: Array[CodeBlockParameter]):
	self.id = id
	self.code_string = code_string
	self.display_string = display_string
	self.type = type
	self.family = family
	self.parameters = parameters

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


static func from_json(dict, manager: CodeBlockManager) -> CodeBlockSpec:
	var id = StringName(dict["id"])
	var family = manager.get_family(StringName(dict["family"]))
	
	var type := CodeBlock.Type.SUBJECT
	match dict["type"]:
		"subject": type = CodeBlock.Type.SUBJECT
		"modifier": type = CodeBlock.Type.MODIFIER
		"action": type = CodeBlock.Type.ACTION
		
	var parameters := [] as Array[CodeBlockParameter]
	
	for parameter_dict in dict["parameters"]:
		var default = parameter_dict["default"]
		var parameter_type = CodeBlockParameter.Type.STRING		
		match parameter_dict["type"]:
			"number": 
				parameter_type = CodeBlockParameter.Type.NUMBER
				default = float(default)
			"integer": 
				parameter_type = CodeBlockParameter.Type.INTEGER
				default = int(default)
			"string":
				parameter_type = CodeBlockParameter.Type.STRING
				default = str(default)
		
		parameters.append(CodeBlockParameter.new(StringName(parameter_dict["id"]), parameter_type, default))
	
	return CodeBlockSpec.new(id, dict["code_string"], dict["display_string"], type, family, parameters)
