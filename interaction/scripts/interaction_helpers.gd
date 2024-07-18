extends Object
class_name InteractionHelpers

static func random_id()->String:
	return str(str(randf_range(0.0, 1.0)).hash())
	
static func random_int32_id()->int:
	return str(randf_range(0.0, 1.0)).hash() % 2147483648

static func position_to_pixel(vector: Vector2)->Vector2:
	return Vector2(round(vector.x * Config.app_render_width), round(vector.y * Config.app_render_height))

static func position_to_normalized(vector: Vector2)->Vector2:
	return Vector2(vector.x / Config.app_render_width, vector.y * Config.app_window_height)
