extends Object
class_name CodeBlockParameter

enum Type {
	INTEGER,
	NUMBER
}

var id: StringName
var type: Type
var default

func _init(id: StringName, type: Type, default):
	self.id = id
	self.type = type
	self.default = default
