extends Object
class_name CodeBlockParameter

enum Type {
	INTEGER,
	NUMBER,
	STRING
}

var id: StringName
var type: Type
var default

func _init(id: StringName, type: Type, default):
	self.id = id
	self.type = type
	self.default = default

func type_tag()->String:
	match type:
		Type.INTEGER: return "i"
		Type.NUMBER: return "f"
		Type.STRING: return "s"
	return "s"
