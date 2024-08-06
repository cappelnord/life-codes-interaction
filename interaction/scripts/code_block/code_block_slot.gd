extends Object
class_name CodeBlockSlot

var id: StringName
var display_string: String
var spec: CodeBlockSpec
var start_position: Vector2
# should be copied when CodeBlock is spawned
var arguments: Dictionary
var family: CodeBlockFamily
var behaviour: CodeBlockBehaviour
var context: String
var can_respawn: bool
var time_to_respawn: float
var despawn_fade_time: float

var _spawn_counter = 0
var _respawn_timer = 0.0

var block: CodeBlock = null
var manager: CodeBlockManager

# this
var deleted := false

# this has become a mess


func _init(spec: CodeBlockSpec, start_position: Vector2, id: StringName = &"", options: Variant = {}):

	if id == &"": id = StringName(str(spec.id) + "-" + InteractionHelpers.random_id())
		
	self.id = id
	self.spec = spec
	self.start_position = start_position

	# see here for options
	self.family = options.get("family", spec.family)
	self.behaviour = options.get("behaviour", CodeBlockBehaviour.get_behaviour("default")) 
	self.context = options.get("context", "")
	self.display_string = options.get("display_string", spec.display_string)
	self.can_respawn = options.get("can_respawn", false)
	self.time_to_respawn = options.get("time_to_respawn", 2)
	self.despawn_fade_time = options.get("despawn_fade_time", 3)

	var arguments = options.get("arguments", [])

	self.arguments = {}
	for argument in arguments:
		self.arguments[argument.parameter.id] = argument	

func process(delta: float):
	_respawn_timer = max(0.0, _respawn_timer - delta)

func register_spawned_block(block: CodeBlock):
	_spawn_counter = _spawn_counter + 1
	self.block = block

func block_was_deleted():
	block = null
	if not can_respawn:
		delete()
	else:
		_respawn_timer = time_to_respawn

func should_spawn() -> bool:
	return block == null and (can_respawn or _spawn_counter == 0) and _respawn_timer <= 0

func delete():
	can_respawn = false
	deleted = true
	if block:
		block.delete()
	block = null
	manager.remove_slot(id)
	print("Delete Slot: " + id)

func get_command_context()->String:
	if context != null and context != "":
		return context
	else:
		return str(id)

func set_properties_from_json(data: Variant):
	if data.has("pos"):
		start_position =  InteractionHelpers.position_to_pixel(Vector2(data["pos"]["x"], data["pos"]["y"]))
	
	if data.has("canRespawn"):
		can_respawn = data["canRespawn"]
	
	if data.has("timeToRespawn"):
		time_to_respawn = data["timeToRespawn"]
	
	# do others make sense here as well? who knows :)

func despawn_from_json(data: Variant):
	if data.has("canRespawn"):
		can_respawn = data["canRespawn"]
	
	if data.has("timeToRespawn"):
		time_to_respawn = data["timeToRespawn"]

	if block == null: return
	
	if data.has("fadeTime"):
		despawn_fade_time = data["fadeTime"]
	
	block.queue_despawn(despawn_fade_time)

static func from_json(data: Variant, manager: CodeBlockManager) -> CodeBlockSlot:
	var spec = manager.get_spec(StringName(data["spec"]))
	var start_position = InteractionHelpers.position_to_pixel(Vector2(data["pos"]["x"], data["pos"]["y"]))
	var id = StringName(data["id"])
	
	var do = data["options"]
	var options = {}
	
	if do.has("family"):
		options["family"] = manager.get_family(StringName(do["family"]))
	
	if do.has("context"):
		options["context"] = do["context"]
	
	if do.has("behaviour"):
		options["behaviour"] = CodeBlockBehaviour.from_json(do["behaviour"])
	
	if do.has("display"):
		options["display_string"] = do["display"]
		
	if do.has("canRespawn"):
		options["can_respawn"] = do["canRespawn"]
	
	if do.has("timeToRespawn"):
		options["time_to_respawn"] = do["timeToRespawn"]
	
	if do.has("fadeTime"):
		options["despawn_fade_time"] = do["fadeTime"]
	
	if do.has("args"):	
		var arguments = [] as Array[CodeBlockArgument]
		var i := 0
		for arg in do["args"]:
			arguments.append(CodeBlockArgument.new(spec.parameters[i], CodeBlockArgument.Type.CONSTANT, arg))
			i = i + 1
		options["arguments"] = arguments
	
	return CodeBlockSlot.new(spec, start_position, id, options)
	
