extends Object
class_name CodeBlockBehaviour

static var _template_dict_initialized := false
static var _template_dict: Dictionary

static func _populate_templates():
	_template_dict = {
		"default": CodeBlockSmoothBrownianBehaviour.new(
			Vector2(40.0, 40.0),
			3.0, 4.0,
			2.0, 4.0,
			0.005
		),
		"nop": CodeBlockNOPBehaviour.new()
	}
	
	_template_dict_initialized = true

static func get_behaviour(key: String)->CodeBlockBehaviour:
	if not _template_dict_initialized: _populate_templates()
	
	if key in _template_dict:
		return _template_dict[key]
	else:
		return _template_dict["default"]

func get_delta_movement(block: CodeBlock, host: CodeBlockBehaviourHost, delta: float)->Vector2:
	return Vector2.ZERO

func is_stateless()->bool:
	return true

func clone()->CodeBlockBehaviour:
	return self
