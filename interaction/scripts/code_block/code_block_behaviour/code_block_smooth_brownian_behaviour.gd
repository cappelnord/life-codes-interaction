extends CodeBlockBehaviour
class_name CodeBlockSmoothBrownianBehaviour

var _range: Vector2

var _from: Vector2
var _to: Vector2
var _current := Vector2.ZERO

var _action_time: float
var _time_elapsed: float

var _min_travel_time: float
var _max_travel_time: float
var _min_wait_time: float
var _max_wait_time: float
var _filter_weight: float

var _waiting_phase := true

func _init(range: Vector2, min_travel_time: float, max_travel_time: float, min_wait_time: float, max_wait_time: float, filter_weight: float):
	self._range = range
	self._min_travel_time = min_travel_time
	self._max_travel_time = max_travel_time
	self._min_wait_time = min_wait_time
	self._max_wait_time = max_wait_time
	self._filter_weight = filter_weight
	
	_look_for_target()

func _look_for_target():
	_from = _current
	_to = Vector2(randf_range(-_range.x, _range.x), randf_range(-_range.y, _range.y))
	
	_action_time = randf_range(_min_travel_time, _max_travel_time)
	_time_elapsed = 0
	_waiting_phase = false

func _wait():
	_waiting_phase = true
	_action_time = randf_range(_min_wait_time, _max_wait_time)
	_time_elapsed = 0

# problem: the process should probably know when it should actulaly not move (or to what extend)

func get_delta_movement(block: CodeBlock, host: CodeBlockBehaviourHost, delta: float)->Vector2:
	var _current_target: Vector2
	_time_elapsed += delta
	if _waiting_phase:
		_current_target = _to
		if _time_elapsed >= _action_time:
			_look_for_target()
	else:
		var x = clamp(_time_elapsed / _action_time, 0.0, 1.0)
		_current_target = _from.lerp(_to, x)
		if _time_elapsed >= _action_time:
			_wait()
	
	# zeno filter
	_current_target = (_current_target * _filter_weight) + (_current * (1.0 - _filter_weight))
	
	var delta_movement := _current_target - _current
	_current = _current + delta_movement * block.behaviour_activity_ramp

	return delta_movement

func clone()->CodeBlockBehaviour:
	return CodeBlockSmoothBrownianBehaviour.new(_range, _min_travel_time, _max_travel_time, _min_wait_time, _max_wait_time, _filter_weight)

