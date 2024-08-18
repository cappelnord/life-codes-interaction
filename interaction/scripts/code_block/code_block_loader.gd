extends RefCounted
class_name CodeBlockLoader

# I guess this should ideally also somehow happen at the startup
# - it could e.g. load the last json. Maybe this could make things
# more robust? But anyways then other things need to be started/figured out.
# ...

func _init():
	pass
	# initialize loader and get ready to feed the CodeBlockManager
	
func loadJSON(jsonPath: String, manager: CodeBlockManager):
	var string := FileAccess.get_file_as_string(jsonPath)
	var dict = JSON.parse_string(string)
	
	for key in dict["familySpecs"]:
		var family := CodeBlockFamily.from_json(dict["familySpecs"][key], manager)
		if family:
			manager.add_family(family)
	
	for key in dict["blockSpecs"]:
		var spec := CodeBlockSpec.from_json(dict["blockSpecs"][key], manager)
		if spec:
			manager.add_spec(spec)
	
	if dict.has("cornerVertices"):
		CornerVertices.update_from_json(dict["cornerVertices"] as Array)
