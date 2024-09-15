extends Sprite2D
class_name CursorHint

var cursor: Cursor


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween_time := 1.25
	var tween := create_tween()
	
	tween.tween_property(self, "scale", Vector2(0, 0), tween_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate", Color(0.75, 0.75, 0.75, 0.75), tween_time)
	tween.tween_callback(self.queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cursor == null: return
	position = cursor.position
