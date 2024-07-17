extends Object
class_name CodeBlockLoader

func _init(path: String):
	pass
	# initialize loader and get ready to feed the CodeBlockManager
	
func load(manager: CodeBlockManager):
	
	# TODO: rethink how families are structured
	
	var universal_family = manager.add_family(CodeBlockFamily.new(
		&"universal_pattern",
		Color.DARK_GRAY,
		[&"clock", &"bowl", &"djembes", &"boomwhacks"],
		false
	))
	
	var clock_family = manager.add_family(CodeBlockFamily.new(
		&"clock",
		Color.DARK_SLATE_GRAY,
		[&"clock"],
		true
	))

	var bowl_family = manager.add_family(CodeBlockFamily.new(
		&"bowl",
		Color.DARK_ORANGE,
		[&"bowl"],
		true
	))
	
	var djembes_family = manager.add_family(CodeBlockFamily.new(
		&"djembes",
		Color.DARK_RED,
		[&"djembes"],
		true
	))
	
	var boomwhacks_family = manager.add_family(CodeBlockFamily.new(
		&"boomwhacks",
		Color.INDIAN_RED,
		[&"boomwhacks"],
		true
	))
	
	var bowl_support_family = manager.add_family(CodeBlockFamily.new(
		&"bowl_support",
		Color.DARK_KHAKI,
		[&"bowl", &"djembes", &"boomwhacks"],
		false
	))
	
	var life_family = manager.add_family(CodeBlockFamily.new(
		&"life",
		Color.DARK_SLATE_BLUE,
		[&"life"],
		false
	))
	
	var clock_spec = manager.add_spec(CodeBlockSpec.new(
		&"clock:clock",
		"clock",
		"clock",
		CodeBlock.Type.SUBJECT,
		clock_family,
		[]
	))
	
	var play_spec = manager.add_spec(CodeBlockSpec.new(
		&"universal_pattern:play",
		"play",
		"play",
		CodeBlock.Type.ACTION,
		universal_family,
		[]
	))
	
	var bowl_spec = manager.add_spec(CodeBlockSpec.new(
		&"bowl:bowl",
		"bowl",
		"bowl",
		CodeBlock.Type.SUBJECT,
		bowl_family,
		[]
	))
	
	var djembes_spec = manager.add_spec(CodeBlockSpec.new(
		&"djembes:djembes",
		"djembes",
		"djembes",
		CodeBlock.Type.SUBJECT,
		djembes_family,
		[]
	))
	
	var boomwhacks_spec = manager.add_spec(CodeBlockSpec.new(
		&"boomwhacks:boomwhacks",
		"boomwhacks",
		"boomwhacks",
		CodeBlock.Type.SUBJECT,
		boomwhacks_family,
		[]
	))
	
	var faster_spec = manager.add_spec(CodeBlockSpec.new(
		&"universal_pattern:faster",
		"faster",
		"faster",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[CodeBlockParameter.new(&"speed", CodeBlockParameter.Type.NUMBER, 2)]
	))
	
	var slower_spec = manager.add_spec(CodeBlockSpec.new(
		&"universal_pattern:slower",
		"slower",
		"slower",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[CodeBlockParameter.new(&"speed", CodeBlockParameter.Type.NUMBER, 2)]
	))
	
	var repeat_sample_spec = manager.add_spec(CodeBlockSpec.new(
		&"bowl_support:repeatSample",
		"repeatSample",
		"repeatSample",
		CodeBlock.Type.MODIFIER,
		bowl_support_family,
		[CodeBlockParameter.new(&"times", CodeBlockParameter.Type.NUMBER, 2)]
	))
	
	var euclid_spec = manager.add_spec(CodeBlockSpec.new(
		&"bowl_support:euclid",
		"euclid",
		"euclid",
		CodeBlock.Type.MODIFIER,
		bowl_support_family,
		[CodeBlockParameter.new(&"a", CodeBlockParameter.Type.NUMBER, 8), CodeBlockParameter.new(&"b", CodeBlockParameter.Type.NUMBER, 8)]
	))
	
	var mute_spec = manager.add_spec(CodeBlockSpec.new(
		&"universal_pattern:mute",
		"mute",
		"mute",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[]
	))
	
	var softer_spec = manager.add_spec(CodeBlockSpec.new(
		&"universal_pattern:softer",
		"softer",
		"softer",
		CodeBlock.Type.MODIFIER,
		universal_family,
		[]
	))
	
	var high_register_spec = manager.add_spec(CodeBlockSpec.new(
		&"bowl:highRegister",
		"highRegister",
		"highRegister",
		CodeBlock.Type.MODIFIER,
		bowl_family,
		[]
	))
	
	var low_register_spec = manager.add_spec(CodeBlockSpec.new(
		&"bowl:lowRegister",
		"lowRegister",
		"lowRegister",
		CodeBlock.Type.MODIFIER,
		bowl_family,
		[]
	))
	
	var life_spec = manager.add_spec(CodeBlockSpec.new(
		&"life:life",
		"life",
		"life",
		CodeBlock.Type.SUBJECT,
		life_family,
		[]	
	))
	
	var emerge_spec = manager.add_spec(CodeBlockSpec.new(
		&"life:emerge",
		"emerge",
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
		[CodeBlockArgument.new(faster_spec.get_parameter(&"speed"), CodeBlockArgument.Type.CONSTANT, 4)]
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

	# manager.add_slot(CodeBlockSlot.new(
	# 	repeat_sample_spec,
	# 	Vector2(900, 900),
	# 	[CodeBlockArgument.new(repeat_sample_spec.get_parameter(&"times"), CodeBlockArgument.Type.CONSTANT, 4)]
	# ))
	
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
		euclid_spec,
		Vector2(1000, 1050),
		[CodeBlockArgument.new(euclid_spec.get_parameter(&"a"), CodeBlockArgument.Type.CONSTANT, 7), CodeBlockArgument.new(euclid_spec.get_parameter(&"b"), CodeBlockArgument.Type.CONSTANT, 16)]
	))
	
	
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(500, 500)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(600, 600)
	))
	

	# manager.add_slot(CodeBlockSlot.new(
	# 	softer_spec,
	# 	Vector2(1100, 1000)
	# ))
	
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
	
	manager.add_slot(CodeBlockSlot.new(
		djembes_spec,
		Vector2(1200, 100)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		play_spec,
		Vector2(1400, 200)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		boomwhacks_spec,
		Vector2(1200, 800)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		play_spec,
		Vector2(1400, 900)
	))
	
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(1200, 900)
	))
	
	manager.add_slot(CodeBlockSlot.new(
		mute_spec,
		Vector2(1000, 900)
	))
	
