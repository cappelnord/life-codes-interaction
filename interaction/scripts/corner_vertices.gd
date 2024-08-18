extends RefCounted
class_name CornerVertices

static var vertices: Array

class CornerVertex:
	var x: float
	var position: Vector2
	
	func _init(x: float, position: Vector2):
		self.x = x
		self.position = position

static func _static_init():
	vertices = [
		CornerVertex.new(0.0, Vector2(-2, 2.5)),
		CornerVertex.new(0.307, Vector2(2, 2.5)),
		CornerVertex.new(0.692, Vector2(2, -2.5)),
		CornerVertex.new(1.0, Vector2(-2, -2.5))
	]

static func update_from_json(json: Array):
	vertices = []
	for vertex: Variant in json:
		var obj := CornerVertex.new(vertex["x"], Vector2(vertex["position"]["x"], vertex["position"]["y"]))
		vertices.append(obj)
