extends RefCounted
class_name CodeBlockBehaviour

static var _template_dict_initialized := false
static var _template_dict: Dictionary

static func _populate_templates():
	var brownian := CodeBlockSmoothBrownianBehaviour.new(
			Vector2(40.0, 40.0),
			3.0, 4.0,
			2.0, 4.0,
			0.005
		)
	
	_template_dict = {
		"default": CodeBlockFallBehaviour.new(
			-600,
			1.0, 3.0,
			2,
			0.05,
			brownian
		),
		"brownian": brownian,
		"nop": CodeBlockNOPBehaviour.new()
	}
	
	_template_dict_initialized = true

static func from_json(data)->CodeBlockBehaviour:
	if data is String:
		return CodeBlockBehaviour.get_behaviour(data)
	#TODO
	else:
		return CodeBlockBehaviour.get_behaviour("nop")

static func get_behaviour(key: String)->CodeBlockBehaviour:
	if not _template_dict_initialized: _populate_templates()
	
	if key in _template_dict:
		return _template_dict[key]
	else:
		return _template_dict["default"]

func initialize(block: CodeBlock, host: CodeBlockBehaviourHost):
	pass

func get_delta_movement(block: CodeBlock, host: CodeBlockBehaviourHost, delta: float)->Vector2:
	return Vector2.ZERO

func is_stateless()->bool:
	return true

func clone()->CodeBlockBehaviour:
	return self
