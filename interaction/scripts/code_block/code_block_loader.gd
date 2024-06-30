extends Object
class_name CodeBlockLoader

func _init(path: String):
	pass
	# initialize loader and get ready to feed the CodeBlockManager
	
func load(manager: CodeBlockManager):
	
	# TODO: rethink how families are structured
	
	var universal_family = manager.add_family(CodeBlockFamily.new(
		&"universal",
		Color.DARK_GRAY,
		[&"clock", &"bowl"]
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
	
	var life_family = manager.add_family(CodeBlockFamily.new(
		&"life",
		Color.DARK_SLATE_BLUE,
		[&"life"]
	))
	
	var clock_spec = manager.add_spec(CodeBlockSpec.new(
		&"clock",
		"clock",
		CodeBlock.Type.SUBJECT,
		clock_family,
		[],
		true
	))
	
	var play_spec = manager.add_spec(CodeBlockSpec.new(
		&"play",
		"play",
		CodeBlock.Type.ACTION,
		universal_family,
		[]
	))
	
	var bowl_spec = manager.add_spec(CodeBlockSpec.new(
		&"bowl",
		"bowl",
		CodeBlock.Type.SUBJECT,
		bowl_family,
		[],
		true
	))
	
	var faster_spec = manager.add_spec(CodeBlockSpec.new(
		&"faster",
		"faster",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[CodeBlockParameter.new(&"speed", CodeBlockParameter.Type.NUMBER, 2)]
	))
	
	var slower_spec = manager.add_spec(CodeBlockSpec.new(
		&"slower",
		"slower",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[CodeBlockParameter.new(&"speed", CodeBlockParameter.Type.NUMBER, 2)]
	))
	
	var repeat_sample_spec = manager.add_spec(CodeBlockSpec.new(
		&"repeatSample",
		"repeatSample",
		CodeBlock.Type.MODIFIER,
		bowl_family,
		[CodeBlockParameter.new(&"times", CodeBlockParameter.Type.NUMBER, 2)]
	))
	
	var euclid_spec = manager.add_spec(CodeBlockSpec.new(
		&"euclid",
		"euclid",
		CodeBlock.Type.MODIFIER,
		bowl_family,
		[CodeBlockParameter.new(&"a", CodeBlockParameter.Type.NUMBER, 8), CodeBlockParameter.new(&"b", CodeBlockParameter.Type.NUMBER, 8)]
	))
	
	var mute_spec = manager.add_spec(CodeBlockSpec.new(
		&"mute",
		"mute",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[]
	))
	
	var softer_spec = manager.add_spec(CodeBlockSpec.new(
		&"softer",
		"softer",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[]
	))
	
	var high_register_spec = manager.add_spec(CodeBlockSpec.new(
		&"highRegister",
		"highRegister",
		CodeBlock.Type.MODIFIER,
		bowl_family,
		[]
	))
	
	var low_register_spec = manager.add_spec(CodeBlockSpec.new(
		&"lowRegister",
		"lowRegister",
		CodeBlock.Type.MODIFIER,
		bowl_family,
		[]
	))
	
	var life_spec = manager.add_spec(CodeBlockSpec.new(
		&"life",
		"life",
		CodeBlock.Type.SUBJECT,
		life_family,
		[]	
	))
	
	var emerge_spec = manager.add_spec(CodeBlockSpec.new(
		&"emerge",
		"emerge",
		CodeBlock.Type.ACTION,
		life_family,
		[]
	))
	
	manager.add_slot(CodeBlockSlot.new(
		clock_spec,
		Vector2(100, 100)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		play_spec,
		Vector2(200, 200)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		bowl_spec,
		Vector2(600, 100)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		play_spec,
		Vector2(700, 200)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		faster_spec,
		Vector2(300, 300),
		[CodeBlockArgument.new(faster_spec.get_parameter(&"speed"), CodeBlockArgument.Type.CONSTANT, 2)]
	))

	manager.add_slot(CodeBlockSlot.new(
		faster_spec,
		Vector2(200, 500),
		[CodeBlockArgument.new(faster_spec.get_parameter(&"speed"), CodeBlockArgument.Type.CONSTANT, 2)]
	))
	
	manager.add_slot(CodeBlockSlot.new(
		slower_spec,
		Vector2(300, 800),
		[CodeBlockArgument.new(faster_spec.get_parameter(&"speed"), CodeBlockArgument.Type.CONSTANT, 2)]
	))
		
	manager.add_slot(CodeBlockSlot.new(
		faster_spec,
		Vector2(400, 400),
		[CodeBlockArgument.new(faster_spec.get_parameter(&"speed"), CodeBlockArgument.Type.CONSTANT, 4)],
		clock_family
	))
	
	manager.add_slot(CodeBlockSlot.new(
		repeat_sample_spec,
		Vector2(700, 700),
		[CodeBlockArgument.new(repeat_sample_spec.get_parameter(&"times"), CodeBlockArgument.Type.CONSTANT, 2)]
	))

	manager.add_slot(CodeBlockSlot.new(
		repeat_sample_spec,
		Vector2(800, 800),
		[CodeBlockArgument.new(repeat_sample_spec.get_parameter(&"times"), CodeBlockArgument.Type.CONSTANT, 3)]
	))

	manager.add_slot(CodeBlockSlot.new(
		repeat_sample_spec,
		Vector2(900, 900),
		[CodeBlockArgument.new(repeat_sample_spec.get_parameter(&"times"), CodeBlockArgument.Type.CONSTANT, 4)]
	))
	
	manager.add_slot(CodeBlockSlot.new(
		euclid_spec,
		Vector2(100, 1050),
		[CodeBlockArgument.new(euclid_spec.get_parameter(&"a"), CodeBlockArgument.Type.CONSTANT, 3), CodeBlockArgument.new(euclid_spec.get_parameter(&"b"), CodeBlockArgument.Type.CONSTANT, 8)]
	))
	
	manager.add_slot(CodeBlockSlot.new(
		euclid_spec,
		Vector2(400, 1050),
		[CodeBlockArgument.new(euclid_spec.get_parameter(&"a"), CodeBlockArgument.Type.CONSTANT, 5), CodeBlockArgument.new(euclid_spec.get_parameter(&"b"), CodeBlockArgument.Type.CONSTANT, 8)]
	))
	
	manager.add_slot(CodeBlockSlot.new(
		euclid_spec,
		Vector2(700, 1050),
		[CodeBlockArgument.new(euclid_spec.get_parameter(&"a"), CodeBlockArgument.Type.CONSTANT, 7), CodeBlockArgument.new(euclid_spec.get_parameter(&"b"), CodeBlockArgument.Type.CONSTANT, 8)]
	))
	
	
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(500, 500)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(600, 600)
	))
	

	manager.add_slot(CodeBlockSlot.new(
		softer_spec,
		Vector2(1100, 1000)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(700, 900)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		life_spec,
		Vector2(800, 400)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		emerge_spec,
		Vector2(900, 600)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		bowl_spec,
		Vector2(1100, 200)
	))

	manager.add_slot(CodeBlockSlot.new(
		play_spec,
		Vector2(1150, 300)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		high_register_spec,
		Vector2(1150, 500)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		low_register_spec,
		Vector2(1150, 600)
	))
	
