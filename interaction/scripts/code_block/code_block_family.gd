extends Object
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
