extends Object
class_name CodeBlockLoader

func _init():
	pass
	# initialize loader and get ready to feed the CodeBlockManager
	
func loadJSON(jsonPath: String, manager: CodeBlockManager):
	var string := FileAccess.get_file_as_string(jsonPath)
	var dict = JSON.parse_string(string)
	
	for familyKey in dict["familySpecs"]:
		_load_family_from_dict(dict["familySpecs"][familyKey], manager)
	
	for blockKey in dict["blockSpecs"]:
		_load_block_specs_from_dict(dict["blockSpecs"][blockKey], manager)

func _load_family_from_dict(dict, manager: CodeBlockManager):
	var id := StringName(dict["id"])
	var quant := dict["quant"] as bool
	
	var matches := [] as Array[StringName]
	for value in dict["matches"]:
		matches.append(StringName(value))
	
	var color := Color(dict["color"]["red"], dict["color"]["green"], dict["color"]["blue"])
	
	# print("Loaded family: " + id)
	manager.add_family(CodeBlockFamily.new(id, color, matches, quant))
	
func _load_block_specs_from_dict(dict, manager: CodeBlockManager):
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
	
	# print("Loaded block spec: " + id)
	manager.add_spec(CodeBlockSpec.new(id, dict["code_string"], dict["display_string"], type, family, parameters))
	
