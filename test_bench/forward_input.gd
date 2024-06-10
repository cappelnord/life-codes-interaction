extends Node2D

var mouse_cursor_controller: MouseCursorController

func _ready():
	if Config.mouse_enable:
		mouse_cursor_controller = find_child("MouseCursorController") as MouseCursorController

func _unhandled_input(event):
	if mouse_cursor_controller:
		mouse_cursor_controller._unhandled_input(event)

func _input(event):
	if mouse_cursor_controller:
		mouse_cursor_controller._input(event)
