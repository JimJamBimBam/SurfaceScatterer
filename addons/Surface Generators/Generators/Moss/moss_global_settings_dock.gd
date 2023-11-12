@tool
extends Control

const VBOX_CONTAINER_NODE_PATH: String = "ScrollContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer"

#static var moss_settings_changed: Signal = StaticSignalsClass.make_signal_with_parameters(self, "moss_settings_changed", [{ "name": "moss_settings", "type": TYPE_OBJECT }])

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

#var moss_generator_nodes: Array[Node] = []

var _send_update: bool = false

func _ready() -> void:
	_moss_colour_colour_picker_button.color_changed.connect(_on_moss_colour_changed)
	_quality_spin_box.value_changed.connect(_on_quality_value_changed)
	# TODO: add the rest of the value_changed signals.
	
#	print(moss_generator_nodes.size())
#	for generator in moss_generator_nodes:
#		print(generator.get_parent().name)


func _process(delta: float) -> void:
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

#	moss_settings_changed.emit(new_moss_settings)
#	print("sending new settings")
