extends SubViewportContainer

@onready var _viewport = $"RenderViewport"

func _unhandled_input(event):
	_viewport.push_unhandled_input(event)
