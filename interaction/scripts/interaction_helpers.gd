extends RefCounted
class_name InteractionHelpers

static func random_id()->String:
	return str(str(randf_range(0.0, 1.0)).hash())
	
static func random_int32_id()->int:
	return str(randf_range(0.0, 1.0)).hash() % 2147483648

static func position_to_pixel(vector: Vector2)->Vector2:
	return Vector2(round(vector.x * Config.app_render_width), round(vector.y * Config.app_render_height))

static func position_to_normalized(vector: Vector2)->Vector2:
	return Vector2(vector.x / Config.app_render_width, vector.y * Config.app_window_height)

static func osc_encode_value(value)->String:
	match(typeof(value)):
		TYPE_INT:
			return "i" + str(value)
		TYPE_BOOL:
			return "b" + str(value)
		TYPE_FLOAT:
			return "f" + str(value)
		TYPE_STRING:
			return "s" + value
		TYPE_STRING_NAME: 
			return "s" + value
	return ""

static func osc_encode_dictionary(data: Variant):
	var ret := ""
	for key in data:
		if ret != "":
			ret = ret + ","
		ret = ret + InteractionHelpers.osc_encode_value(key) + "," + InteractionHelpers.osc_encode_value(data[key])
	return ret
