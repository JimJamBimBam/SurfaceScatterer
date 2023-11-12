@tool
extends EditorPlugin

var moss_generator_dock: Control

# TODO: Replace with a generate_keys()
# method that uses the Folders in "Surface Generators/Generators"
# as the keys
var generator_nodes: Dictionary = {"Moss": []} 

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	# Replace with load() method so that I can dynaically load in file paths of the dockers
	moss_generator_dock = preload("Generators/Moss/moss_generator_global_settings_dock.tscn").instantiate()
	assert(moss_generator_dock != null, "ERROR: Moss Generator dock was not added properly")
	add_control_to_dock(DOCK_SLOT_LEFT_BL, moss_generator_dock)
	add_custom_type("Moss Generator", "Node3D", preload("Generators/Moss/moss_generator.gd"), preload("res://icon.svg"))
	
	# Connect scene_change to docker so that it can update the generator nodes
#	scene_changed.connect(moss_generator_dock._find_generator_nodes())

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("Moss Generator")
	remove_control_from_docks(moss_generator_dock)
	moss_generator_dock.free()
#	assert(moss_generator_dock.is_queued_for_deletion(), "ERROR: Moss Generator dock was not removed properly")

## Used to add all available nodes from each generator type into a dictionary
func add_to_generator_nodes_dictionary(key: String, value: Array[Node]) -> void:
	if(generator_nodes.has(key)):
		push_error("%s already exists in generator_nodes dictionary." % key)
		return
	generator_nodes[key] = value

func replace_values_in_generator_nodes_dictionary(key: String, value: Array[Node]) -> void:
	generator_nodes[key] = value

func remove_from_generator_nodes_dictionary(key: String) -> void:
	generator_nodes.erase(key)
