extends Sprite2D
class_name CodeBlockHint

var block: CodeBlock
var delay: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = block.text_box_size
	var tween_time := 0.25
	var tween := create_tween()
	
	tween.tween_interval(delay)
	tween.tween_callback(self._flash_block)
	tween.tween_property(self, "scale", block.text_box_size * 2, tween_time)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), tween_time)
	tween.tween_callback(self.queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if block == null: return
	position = block.position + (block.text_box_size * 0.5)

func _flash_block():
	if block == null: return
	block.visual.flash()
