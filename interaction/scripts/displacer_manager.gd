extends Node
class_name DisplacerManager

static var _displacer_node = preload("res://interaction/nodes/displacer_node.tscn")

var displacers : Array[Displacer] = []
var _visible := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Config.app_enable_displacers: return
	
	_spawn(
		Vector2(5450, 600),
		Vector2(400, 400),
		Vector2(-1, 0),
		false
	)
	
	_spawn(
		InteractionHelpers.position_to_pixel(Vector2(0.2805, 0.5)),
		Vector2(30, 1200),
		Vector2(-1, 0),
		true
	)
	
	_spawn(
		InteractionHelpers.position_to_pixel(Vector2(0.662, 0.5)),
		Vector2(30, 1200),
		Vector2(-1, 0),
		true
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var block_set = Dictionary()
	
	for displacer in displacers:
		displacer.add_blocks_to_displace(block_set)
	
	for block in block_set.keys():
		var displacers = block_set[block].keys()
		# TODO: act sensibly if there is more than 1 displacers
		displacers[0].displace_block(block)
			

func _spawn(position: Vector2, size: Vector2, vector: Vector2, allow_x_flip:bool=false):
	var node = _displacer_node.instantiate() as Displacer
	node.set_size_and_position(position, size, vector, allow_x_flip)
	node.visible = _visible
	displacers.append(node)
	add_child(node)

func toggle_visibility():
	_visible = not _visible
	for displacer in displacers:
		displacer.visible = _visible
