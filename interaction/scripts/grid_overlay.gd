extends Node
class_name GridOverlay

var _grid_cell = preload("res://interaction/nodes/grid_cell.tscn")
var _visible = false

func show():
	var step_x: float = 1.0 / Config.grid_divisions_x as float
	var step_y: float = 1.0 / Config.grid_divisions_y as float
	
	var step_pixel_x = Config.app_render_width * step_x
	var step_pixel_y = Config.app_render_height * step_y
	
	var grid_scale = Vector2(step_pixel_x / 256.0, step_pixel_y / 256.0)

	# TODO: How does range work?
	for xi in range(Config.grid_divisions_x):
		for yi in range(Config.grid_divisions_y):
			var pos = Vector2(xi * step_x, yi * step_y)
			var text = ("%.2f" % pos.x) + " @ " + ("%.2f" % pos.y)
			
			var cell = _grid_cell.instantiate() as Node2D
			cell.position = InteractionHelpers.position_to_pixel(pos)
			(cell.find_child("Sprite") as Sprite2D).scale = grid_scale
			(cell.find_child("Label") as Label).text = text
			add_child(cell)
	
	_visible = true

	
func hide():
	for n in get_children():
		remove_child(n)
		n.queue_free()
	
	_visible = false
	
	
func toggle():
	if _visible:
		hide()
	else:
		show()
