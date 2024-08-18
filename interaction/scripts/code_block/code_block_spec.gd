extends RefCounted
class_name CodeBlockSpec

class CodeBlockEffects:
	var sets_values: Array[StringName]
	var modifies_values: Array[StringName]
	var mutes: bool
	var track_effects: bool
		
	func _init(sets_values: Array[StringName], modifies_values: Array[StringName], mutes: bool):
		self.sets_values = sets_values
		self.modifies_values = modifies_values
		self.mutes = mutes
		self.track_effects = (self.sets_values.size() > 0) || (self.modifies_values.size() > 0)

var id: StringName
var code_string: String
var display_string: String
var type: CodeBlock.Type
var family: CodeBlockFamily
var parameters: Array[CodeBlockParameter]
var effects: CodeBlockEffects

func _init(id: StringName, code_string: String, display_string: String, type: CodeBlock.Type, family: CodeBlockFamily, parameters: Array[CodeBlockParameter], effects: CodeBlockEffects):
	self.id = id
	self.code_string = code_string
	self.display_string = display_string
	self.type = type
	self.family = family
	self.parameters = parameters
	self.effects = effects

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
	
	# build parameters
		
	var parameters := [] as Array[CodeBlockParameter]
	
	for parameter_dict in dict["parameters"]:
		var hide = null
		if parameter_dict.has("hide"):
			hide = parameter_dict["hide"]
		
		var default = parameter_dict["default"]
		var parameter_type = CodeBlockParameter.Type.STRING		
		match parameter_dict["type"]:
			"number": 
				parameter_type = CodeBlockParameter.Type.NUMBER
				default = float(default)
				if hide != null: hide = float(hide)
			"integer": 
				parameter_type = CodeBlockParameter.Type.INTEGER
				default = int(default)
				if hide != null: hide = int(hide)
			"string":
				parameter_type = CodeBlockParameter.Type.STRING
				default = str(default)
				if hide != null: hide = str(hide)
		
		parameters.append(CodeBlockParameter.new(StringName(parameter_dict["id"]), parameter_type, default, hide))
	
	
	# build the effects info
	
	var mutes = false
	var sets_values: Array[StringName] = []
	var modifies_values: Array[StringName] = []
	
	if dict.has("mutes"):
		mutes = dict["mutes"]
	
	if dict.has("setsValues"):
		for name in (dict["setsValues"] as Array[String]):
			sets_values.append(StringName(name))
			
	if dict.has("modifiesValues"):
		for name in (dict["modifiesValues"] as Array[String]):
			modifies_values.append(StringName(name))
	
	var effects := CodeBlockEffects.new(sets_values, modifies_values, mutes)
	
	return CodeBlockSpec.new(id, dict["code_string"], dict["display_string"], type, family, parameters, effects)
