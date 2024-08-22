extends Node
class_name CodeBlockHintsManager

var hints: Array[StringName] = []
@onready var _code_block_manager: CodeBlockManager = $"../CodeBlockManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hints.size() == 0: return


func clear():
	hints = []

