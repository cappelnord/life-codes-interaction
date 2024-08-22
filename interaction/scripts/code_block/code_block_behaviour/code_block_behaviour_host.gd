extends RefCounted
class_name CodeBlockBehaviourHost

# this needs some rethinking; the code block slot will know the initial behaviour and therefore
# it can already set it at the beginning ...

class CodeBlockBehaviourReference:
	var behaviour: CodeBlockBehaviour
	var amount := 1.0
	
	func _init(behaviour: CodeBlockBehaviour, amount: float=1.0):
		self.behaviour = behaviour
		self.amount = amount
	
	func process(delta: float):
		pass

var _behaviours: Array[CodeBlockBehaviourReference] = []

func get_delta_movement(block: CodeBlock, delta: float) -> Vector2:
	var ret := Vector2.ZERO
	
	for ref in _behaviours:
		ref.process(delta)
		ret = ret + ref.behaviour.get_delta_movement(block, self, delta)

	return ret

func replace_behaviour(behaviour: CodeBlockBehaviour):
	_behaviours.clear()
	_behaviours.append(CodeBlockBehaviourReference.new(behaviour))

func ignore_interaction_boundary()->bool:
	var ret := false
	for ref in _behaviours:
		ret = ret or ref.behaviour.ignore_interaction_boundary()
	return ret
