extends Sprite2D
class_name CodeBlockHint

var block: CodeBlock

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if block == null: return
	position = block.position + (block.visual.scale * 0.5)
	scale = block.visual.scale * 2.0
	
	pass
