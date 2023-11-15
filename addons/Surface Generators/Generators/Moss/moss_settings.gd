class_name MossSettings extends SurfaceSettings

var shell_colour: Color
var shell_count: int
var shell_length: float
var density: float  
var noise_min: float
var noise_max: float
var thickness: float
var attenuation: float
var occlusion_bias: float 
var shell_distance_attenuation: float
var stiffness: float
var displacement_strength: float

func _init(init_colour: Color, init_count: int, init_length: float, init_density: float,
		init_noise_min: float, init_noise_max: float, init_thickness: float,
		init_attenuation: float, init_occlusion_bias: float, init_distance_attenuation: float,
		init_stiffness: float, init_displacement_strength: float) -> void:
	
	shell_colour = init_colour
	shell_count = init_count
	shell_length = init_length
	density = init_density
	noise_min = init_noise_min
	noise_max = init_noise_max
	thickness = init_thickness
	attenuation = init_attenuation
	occlusion_bias = init_occlusion_bias
	shell_distance_attenuation = init_distance_attenuation
	stiffness = init_stiffness
	displacement_strength = init_displacement_strength

func get_class() -> String:
	return "MossSettings"

func is_class(class_to_compare: String) -> bool:
	return class_to_compare == get_class() or super(class_to_compare)
