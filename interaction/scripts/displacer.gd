extends Sprite2D
class_name Displacer

@onready var _collider = $"Area2D" as Area2D
var _vector: Vector2
var _allow_x_flip: bool = false

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_size_and_position(position: Vector2, size: Vector2, vector: Vector2, allow_x_flip:bool=false):
	self.position = position
	self.scale = size
	_allow_x_flip = allow_x_flip
	_vector = vector

func add_blocks_to_displace(block_set: Dictionary):
	var areas = _collider.get_overlapping_areas()
	for area in areas:
		var block := area.block as CodeBlock
		
		if block.grabbed: continue
		if block.despawning: continue
		
		if block.group != null:
			block = block.group.head
		
		if block != null:
			if not block_set.has(block):
				block_set[block] = {}
			block_set[block][self] = true

func displace_block(block: CodeBlock):
	var this_vector = _vector
	if _allow_x_flip and block.position.x + (block.text_box_size.x * 0.5) > position.x:
		this_vector.x = this_vector.x * -1
	block.displacement_vector = this_vector * Config.app_displacement_speed
