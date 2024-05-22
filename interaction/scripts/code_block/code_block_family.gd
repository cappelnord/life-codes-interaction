extends Object
class_name CodeBlockFamily

var id: StringName
var color: Color
var matches: Array = []

func _init(id: StringName, color: Color, matches: Array):
	self.id = id
	self.color = color
	self.matches = matches

func is_compatible(family: CodeBlockFamily):
	if matches[0] == &"*": return true
	for cand in matches:
		if cand == family.id: return true
	return false
