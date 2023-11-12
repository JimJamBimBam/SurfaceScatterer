# TODO: Fix docker so that it checks everytime a scene is changed so that it can update its list of nodes that hold moss generator scripts
# TODO: Give class preloads better names, similar to something they would get if they were global classes, like "MossGenerator"
# TODO: Move most of the functionality of connecting signals and editing values/finding nodes to the class that extends "EditorPlugin". This way, one time methods are only called once.

@tool
extends Control

# Class references
#const NodeMethods = preload("res://addons/Surface Generators/Utility/node_methods.gd")


const VBOX_CONTAINER_NODE_PATH: String = "ScrollContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer"

static var moss_settings_changed: Signal = StaticSignalsClass.make_signal_with_parameters(self, "moss_settings_changed", [{ "name": "moss_settings", "type": TYPE_OBJECT }])
static var test_float: float

@onready var _moss_colour_colour_picker_button: ColorPickerButton = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "MossColour_HBoxContainer/MossColour")
@onready var _quality_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "Quality_HBoxContainer/Quality")
@onready var _shell_length_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "ShellLength_HBoxContainer/ShellLength")
@onready var _density_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "Density_HBoxContainer/Density")
@onready var _noise_minimum_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "MinNoise_HBoxContainer/MinNoise")
@onready var _noise_maximum_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "MaxNoise_HBoxContainer/MaxNoise")
@onready var _thickness_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "Thickness_HBoxContainer/Thickness")
@onready var _attenuation_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "Attenuation_HBoxContainer/Attenuation")
@onready var _occlusion_bias_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "OcclusionBias_HBoxContainer/OcclusionBias")
@onready var _shell_distance_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "ShellDistance_HBoxContainer/ShellDistance")
@onready var _stiffness_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "Stiffness_HBoxContainer/Stiffness")
@onready var _displacement_strength_spin_box: SpinBox = get_node(VBOX_CONTAINER_NODE_PATH + "/" + "DisplacementStrength_HBoxContainer/DisplacementStrength")

var moss_generator_nodes: Array[Node] = []

var _send_update: bool = false

func _ready() -> void:
#	_emit_update_signal()
	
	_moss_colour_colour_picker_button.color_changed.connect(_on_moss_colour_changed)
	_quality_spin_box.value_changed.connect(_on_quality_value_changed)
	
	moss_generator_nodes = get_nodes_that_are_of(MossGenerator, get_tree().edited_scene_root)
	
	print(moss_generator_nodes.size())
	for generator in moss_generator_nodes:
#		generator as MossGenerator
		
		print(generator.get_parent().name)

func _process(delta: float) -> void:
#	if(_send_update):
#		_emit_update_signal()
	pass


func _on_moss_colour_changed(_value: Color) -> void:
	_emit_update_signal()
	pass

func _on_quality_value_changed(_value: float) -> void:
	_emit_update_signal()
	pass

func _emit_update_signal() -> void:
	var new_moss_settings = MossSettings.new(
		_moss_colour_colour_picker_button.color,
		_quality_spin_box.value,
		_shell_length_spin_box.value,
		_density_spin_box.value,
		_noise_minimum_spin_box.value,
		_noise_maximum_spin_box.value,
		_thickness_spin_box.value,
		_attenuation_spin_box.value,
		_occlusion_bias_spin_box.value,
		_shell_distance_spin_box.value,
		_stiffness_spin_box.value,
		_displacement_strength_spin_box.value
		)

	moss_settings_changed.emit(new_moss_settings)
	print("sending new settings")


func get_nodes_that_are_of(type: Variant, node: Node) -> Array[Node]:
	var objects_array: Array[Node] = []
	for child in NodeMethods.get_all_children_in(node):
		print(child.get_class())
		if is_instance_of(child, type):
			objects_array.push_back(child)
	return objects_array


#func get_all_children(node: Node) -> Array:
#	var nodes : Array = []
#	for N in node.get_children():
#		if N.get_child_count() > 0:
#			# Append the child that has children to the end of the array.
#			nodes.append(N)
#			# Append all of it's children as well
#			nodes.append_array(get_all_children(N))
#		else:
#			# Append the child that has no children to the end of the array
#			nodes.append(N)
#	return nodes


func _find_moss_generator_nodes(root_node: Node) -> void:
	# if the scene is new, then no generator nodes could exist so return
	if(root_node == null):
		return
	
	# Go through and find all the children of the root_node
	#var children_of_root_node: Array[Node] = get_all_children(root_node)
	var moss_generator_nodes = get_nodes_that_are_of(MossGenerator, root_node)
	
