extends Node2D

var mouse_cursor_controller: MouseCursorController

@onready var viewport: SubViewport = $RenderViewport

func _ready():
	if Config.mouse_enable:
		mouse_cursor_controller = find_child("MouseCursorController") as MouseCursorController
	
	viewport.size = Vector2i(Config.app_render_width, Config.app_render_height)
	get_window().size = Vector2i(Config.app_window_width, Config.app_window_height)
	# get_window().content_scale_size = Vector2i(Config.app_window_width, Config.app_window_height)

func _unhandled_input(event):
	if mouse_cursor_controller:
		mouse_cursor_controller._unhandled_input(event)

func _input(event):
	if mouse_cursor_controller:
		mouse_cursor_controller._input(event)
