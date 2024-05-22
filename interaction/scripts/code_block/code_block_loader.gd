extends Object
class_name CodeBlockLoader

func _init(path: String):
	pass
	# initialize loader and get ready to feed the CodeBlockManager
	
func load(manager: CodeBlockManager):
	var universal_family = manager.add_family(CodeBlockFamily.new(
		&"universal",
		Color.DARK_GRAY,
		[&"*"]
	))
	
	var clock_family = manager.add_family(CodeBlockFamily.new(
		&"clock",
		Color.DARK_SLATE_GRAY,
		[&"clock"]
	))

	var bowl_family = manager.add_family(CodeBlockFamily.new(
		&"bowl",
		Color.DARK_ORANGE,
		[&"bowl"]
	))
	
	var clock_spec = manager.add_spec(CodeBlockSpec.new(
		&"clock",
		"clock",
		CodeBlock.Type.SUBJECT,
		clock_family,
		[]
	))
	
	var clock_play_spec = manager.add_spec(CodeBlockSpec.new(
		&"play",
		"play",
		CodeBlock.Type.ACTION,
		clock_family,
		[]
	))
	
	var bowl_spec = manager.add_spec(CodeBlockSpec.new(
		&"bowl",
		"bowl",
		CodeBlock.Type.SUBJECT,
		bowl_family,
		[]
	))
	
	var bowl_play_spec = manager.add_spec(CodeBlockSpec.new(
		&"play",
		"play",
		CodeBlock.Type.ACTION,
		bowl_family,
		[]
	))
	
	var faster_spec = manager.add_spec(CodeBlockSpec.new(
		&"faster",
		"faster",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[CodeBlockParameter.new(&"speed", CodeBlockParameter.Type.NUMBER, 2)]
	))
	
	var mute_spec = manager.add_spec(CodeBlockSpec.new(
		&"mute",
		"mute",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[]
	))
	
	manager.add_slot(CodeBlockSlot.new(
		clock_spec,
		Vector2(100, 100)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		clock_play_spec,
		Vector2(200, 200)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		bowl_spec,
		Vector2(600, 100)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		bowl_play_spec,
		Vector2(700, 200)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		faster_spec,
		Vector2(300, 300),
		[CodeBlockArgument.new(faster_spec.get_parameter(&"speed"), CodeBlockArgument.Type.CONSTANT, 2)]
	))
	
	manager.add_slot(CodeBlockSlot.new(
		faster_spec,
		Vector2(400, 400),
		[CodeBlockArgument.new(faster_spec.get_parameter(&"speed"), CodeBlockArgument.Type.CONSTANT, 4)],
		clock_family
	))
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(500, 500)
	))
	
