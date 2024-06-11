extends Node

class_name CursorEvent

enum Type {
	MOVE,
	MOVE_DELTA,
	PRESS,
	RELEASE,
	ATTEMPT_TOGGLE_GRAB,
}

var type: CursorEvent.Type
var vector: Vector2

func _init(type: CursorEvent.Type, vector: Vector2 = Vector2.ZERO):
	self.type = type
	self.vector = vector
