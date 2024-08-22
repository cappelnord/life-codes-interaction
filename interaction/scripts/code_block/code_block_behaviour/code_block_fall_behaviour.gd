extends CodeBlockBehaviour
class_name CodeBlockFallBehaviour

var _base_behaviour: CodeBlockBehaviour
var _current_y: float
var _fall_height: float
var _fall_pow: float
var _normalized_fall_speed: float
var _fall_value := 1.0
var _start_y: float
var _min_fall_time: float
var _max_fall_time: float
var _filter_weight: float
var _block
var _went_under := false


# fall with pow, dampen it, add base behaviour

func _init(start_y: float, min_fall_time: float, max_fall_time: float, fall_pow: float, filter_weight: float, base_behaviour: CodeBlockBehaviour):
	self._start_y = start_y
	self._normalized_fall_speed = 1.0 / randf_range(min_fall_time, max_fall_time)
	self._fall_pow = fall_pow
	self._base_behaviour = base_behaviour.clone()
	self._filter_weight = filter_weight
	
	self._min_fall_time = min_fall_time
	self._max_fall_time = max_fall_time

func initialize(block: CodeBlock, host: CodeBlockBehaviourHost):
	_fall_height = block.position.y - _start_y
	
	_block = block
	
	block.position.y = _start_y
	block.subpixel_position.y = _start_y
	
	_current_y = 0


func get_delta_movement(block: CodeBlock, host: CodeBlockBehaviourHost, delta: float)->Vector2:
		
	_fall_value = max(_fall_value - (delta * _normalized_fall_speed), 0.0)

	var new_y := lerpf(_fall_height, 0, pow(_fall_value, _fall_pow))
	new_y = new_y * _filter_weight + (1.0 - _filter_weight) * _current_y
	
	var fall_delta = Vector2(0, new_y - _current_y) 
	
	_current_y = _current_y + fall_delta.y * block.behaviour_activity_ramp
	
	return fall_delta + _base_behaviour.get_delta_movement(block, host, delta)
	

func clone()->CodeBlockBehaviour:
	return CodeBlockFallBehaviour.new(_start_y, _min_fall_time, _max_fall_time, _fall_pow, _filter_weight, _base_behaviour)


func ignore_interaction_boundary()->bool:
	_went_under = _went_under or (_block.position.y > Config.app_interaction_boundary_topleft.y)
	return not _went_under

