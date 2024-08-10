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
var hide

func _init(id: StringName, type: Type, default, hide):
	self.id = id
	self.type = type
	self.default = default
	self.hide = hide

func type_tag()->String:
	match type:
		Type.INTEGER: return "i"
		Type.NUMBER: return "f"
		Type.STRING: return "s"
	return "s"
