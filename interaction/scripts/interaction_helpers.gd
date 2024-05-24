extends Object
class_name InteractionHelpers

static func random_id()->String:
	return str(str(randf_range(0.0, 1.0)).hash())
	
static func random_int_id()->int:
	return str(randf_range(0.0, 1.0)).hash()
