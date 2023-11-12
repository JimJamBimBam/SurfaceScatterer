#TODO: Use EditorPlugin.scene_changed to find all the nodes in that scene that contain Generator script.

@tool
extends EditorPlugin

const GENERATORS_FILE_PATH: String = "res://addons/Surface Generators/Generators/"
const MAX_LOOP_CYCLES: int = 10

# TODO: Convert this into a internal class that holds:
# The Control and dictionary of nodes.
# This way, new surface generators can be created on the fly and added to the dock
var moss_generator_dock: Control

# TODO: Replace with a generate_keys()
# method that uses the Folders in "Surface Generators/Generators"
# as the keys
## Contains references for all generator nodes in the project.
## Stores each key/value pair as a string/Array[SurfaceGenerator3D].
## Generates keys at startup. Uses the names of the Folders in
## /Surface Generators/Generators directory as the keys
var generator_nodes: Dictionary = {} #_generate_keys_from_directory(GENERATORS_FILE_PATH)

func _enter_tree() -> void:
	generator_nodes = _generate_keys_from_directory(GENERATORS_FILE_PATH)
	
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
	
	# Replace with system that traverses list of dockers and frees them.
	moss_generator_dock.free()
	assert(moss_generator_dock == null, "ERROR: Moss Generator dock was not removed properly")

## Generates a new dictionary from the folders in a particular directory.
## ONLY USE AT START UP.
## CALLING THE SAME KEY NAME WILL OVERRWRITE EXISTING DATA.
func _generate_keys_from_directory(file_path: String) -> Dictionary:
	var temp_dictionary: Dictionary = {}
	var dir: DirAccess = DirAccess.open(GENERATORS_FILE_PATH)
	var directories: PackedStringArray = dir.get_directories()
	print("The directories in the directory are: %s" % directories)
	for folder in directories:
		temp_dictionary[folder] = []
	return temp_dictionary
	

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
