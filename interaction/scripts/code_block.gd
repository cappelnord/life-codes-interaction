extends Node2D
class_name  CodeBlock

enum Type {
	SUBJECT,
	ACTION,
	# add ephemeral action here?
	MODIFIER
}

var slot

# Called when the node enters the scene tree for the first time.
func _ready():
	position = slot.start_position
	# copy everything over from slot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move(new_position: Vector2):
	position = new_position
