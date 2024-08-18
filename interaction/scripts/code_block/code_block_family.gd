extends RefCounted
class_name CodeBlockFamily

var id: StringName
var color: Color
var matches: Array[StringName] = []
var quant: bool

func _init(id: StringName, color: Color, matches: Array[StringName], quant: bool):
	self.id = id
	self.color = color
	self.matches = matches
	self.quant = quant

func is_compatible(family: CodeBlockFamily):
	if matches[0] == &"*": return true
	for cand in matches:
		if cand == family.id: return true
	return false

static func from_json(dict, manager: CodeBlockManager) -> CodeBlockFamily:
	var id := StringName(dict["id"])
	var quant := dict["quant"] as bool
	
	var matches := [] as Array[StringName]
	for value in dict["matches"]:
		matches.append(StringName(value))
	
	var color := Color(dict["color"]["red"], dict["color"]["green"], dict["color"]["blue"])
	
	# print("Loaded family: " + id)
	return CodeBlockFamily.new(id, color, matches, quant)
