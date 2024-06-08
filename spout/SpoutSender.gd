extends Node

var spout

@export var viewport: Viewport
@export var spout_name: String = "LifeCodes"

func _ready():
	if OS.get_name() == "Windows":
		RenderingServer.frame_post_draw.connect(_on_frame_post_draw)
		spout = ClassDB.instantiate(&"Spout")
		spout.set_sender_name(spout_name)
	
func _on_frame_post_draw():
	if spout != null:
		var viewport_texture = RenderingServer.viewport_get_texture(viewport.get_viewport_rid())
		var handle = RenderingServer.texture_get_native_handle(viewport_texture)
		
		# 3553 = GL_TEXTURE_2D in the Open GL API (Texture Target)
		spout.send_texture(handle, 3553, viewport.size.x, viewport.size.y, false, 0)

