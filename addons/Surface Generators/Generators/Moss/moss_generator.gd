@tool
class_name MossGenerator extends SurfaceGenerator3D

# TODO: Have a global variable that can control all moss generators sheel count. (quality versus speed)
## Reference to the mesh that the moss will draw onto
# TODO: Have way of telling if values are not defaults by storing default values at start
# then comparing them when global settings is updated and refusing to update the value if it has changed from the default
#const MossShader: Shader = preload("moss_shader.gdshader")
#const MossSettings: Resource = preload("moss_settings.gd")
#var MOSS_GLOBAL_SETTINGS_DOCK: = preload("moss_global_settings_dock.gd")

## Special variable. Keeps track of the current index layer a mesh layer is on.
var _shell_index: int:  # This is the current shell layer being operated on, it ranges from 0 -> _ShellCount 
	set(new_shell_index):
		_shell_index = new_shell_index
		if moss_shader_material:
			pass
			#_update_setting(MossShaderParameters.SHELL_INDEX, new_shell_index)
			
@export var _shell_colour: Color = Color.WHITE:
	set(new_shell_colour):
		_shell_colour = new_shell_colour
		if moss_shader_material:
			_update_setting(MossShaderParameters.SHELL_COLOUR, new_shell_colour)
@export var _object_scale: Vector2 = Vector2.ONE:
	set(new_object_scale):
		_object_scale = new_object_scale
		if moss_shader_material != null:
			_update_setting(MossShaderParameters.OBJECT_SCALE, new_object_scale)

@export var _shell_count: int = 8: # This is the total number of shells, useful for normalizing the shell index
	set(new_shell_count):
		_shell_count = new_shell_count
		if moss_shader_material:
			_update_number_of_shell_layers()
@export var _shell_length: float = 1.0: # This is the amount of distance that the shells cover, if this is 1 then the shells will span across 1 world space unit
	set(new_shell_length):
		_shell_length = new_shell_length
		if moss_shader_material:
			_update_setting(MossShaderParameters.SHELL_LENGTH, new_shell_length)
@export var _density: float = 100.0:  # This is the density of the strands, used for initializing the noise
	set(new_density):
		_density = new_density
		if moss_shader_material:
			_update_setting(MossShaderParameters.DENSITY, new_density)
@export var _noise_min: float = 0.0:
	set(new_noise_min):
		_noise_min = new_noise_min
		if moss_shader_material:
			_update_setting(MossShaderParameters.NOISE_MIN, new_noise_min)
@export var _noise_max: float = 0.9: # This is the range of possible hair lengths, which the hash then interpolates between 
	set(new_noise_max):
		_noise_max = new_noise_max
		if moss_shader_material:
			_update_setting(MossShaderParameters.NOISE_MAX, new_noise_max)
@export var _thickness: float = 0.2: # This is the thickness of the hair strand
	set(new_thickness):
		_thickness = new_thickness
		if moss_shader_material:
			_update_setting(MossShaderParameters.THICKNESS, new_thickness)
@export var _attenuation: float = 0.1: # This is the exponent on the shell height for lighting calculations to fake ambient occlusion (the lack of ambient light)
	set(new_attenuation):
		_attenuation = new_attenuation
		if moss_shader_material:
			_update_setting(MossShaderParameters.ATTENUATION, new_attenuation)
@export var _occlusion_bias: float = 0.1: # This is an additive constant on the ambient occlusion in order to make the lighting less harsh and maybe kind of fake in-scattering
	set(new_occlusion_bias):
		_occlusion_bias = new_occlusion_bias
		if moss_shader_material:
			_update_setting(MossShaderParameters.OCCLUSION_BIAS, new_occlusion_bias)
@export var _shell_distance_attenuation: float = 0.1: # This is the exponent on determining how far to push the shell outwards, which biases shells downwards or upwards towards the minimum/maximum distance covered
	set(new_shell_distance_attenuation):
		_shell_distance_attenuation = new_shell_distance_attenuation
		if moss_shader_material:
			_update_setting(MossShaderParameters.SHELL_DISTANCE_ATTENUATION, new_shell_distance_attenuation)

@export_category("Physics Settings")
@export var _stiffness: float:
	set(new_stiffness):
		_stiffness = new_stiffness
		if moss_shader_material:
			_update_setting(MossShaderParameters.CURVATURE, new_stiffness)
@export var _displacement_strength: float:
	set(new_displacement_strength):
		_displacement_strength = new_displacement_strength
		if moss_shader_material:
			_update_setting(MossShaderParameters.DISPLACEMENT_STRENGTH, new_displacement_strength)

@export var moss_shader_material: ShaderMaterial

## Keeps a reference to all the shells. Makes it easier to change settings.
@export var _shells: Array[MeshInstance3D] = []

func _ready() -> void:
	super()
	
	# Has mesh generation happened before based on the children of moss_generator
	if _has_generator_run():
		return
	
	_generate_surface()
	print("%s, the mesh attached to %s" % [self.name, attached_mesh.name])


func _has_generator_run() -> bool:
	return get_child_count(true) > 0


func _generate_surface():
	# Make sure that we have a mesh to generate a surface on first.
	if attached_mesh == null:
		return
		

	# Generate mesh shells for the moss material shader,
	# using copies of the base mesh to do this.
	for i in _shell_count:
		var material_settings: SurfaceSettings = MossSettings.new(
			_shell_colour,
			_shell_count,
			_shell_length,
			_density,
			_noise_min,
			_noise_max,
			_thickness,
			_attenuation,
			_occlusion_bias,
			_shell_distance_attenuation,
			_stiffness,
			_displacement_strength
		)
		
		var mesh_shell: MeshInstance3D = _create_shell_layer(i)
		
		# Finish shell creation by adding as child to moss generator.
		add_child(mesh_shell)
		mesh_shell.set_owner(self)
		_shells.push_back(mesh_shell)

func _create_shell_layer(index: int) -> MeshInstance3D:
	var mesh_shell: MeshInstance3D = attached_mesh.duplicate()
	#Apply name for better visiblity in editor
	mesh_shell.name = "mesh_shell_ %02d" % index
	
	# Set up shader material for the given shell
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = surface_shader
	var index_parameter_as_string: String = MossShaderParameters.keys()[MossShaderParameters.SHELL_INDEX].to_lower()
	material.set_shader_parameter(index_parameter_as_string, index)
	
	# Apply the shader material to the mesh shells
	mesh_shell.set_surface_override_material(0, material)
	return mesh_shell


func _update_setting(parameter_to_change: MossShaderParameters, value: Variant) -> void:
	print("Settings updated")
	var parameter_as_string: String = MossShaderParameters.keys()[parameter_to_change].to_lower()
	print(parameter_as_string)
	# Want to return the shader material passed in but with new settings
	moss_shader_material.set_shader_parameter(parameter_as_string, value)

## Updates the number of shells in the mesh shader by the difference in the number of shells and the _shell_count
func _update_number_of_shell_layers() -> void:
	# Check to see if number of shells is larger or smaller than shell_count.
	var match_check: int = _shells.size() - _shell_count
	print(match_check)
	match match_check:
		# Yes. We need more layers. Create one.
		-1:
			var new_shell: MeshInstance3D = _create_shell_layer(_shell_count - 1)
			_shells.push_back(new_shell)
		#No. We need less layers. Remove one.
		1:
			var shell_to_remove: MeshInstance3D = _shells.pop_back()
			if shell_to_remove: # Check incase the shell_count is <= 0 and pop_back returns null.
				shell_to_remove.queue_free()
		_:
			print_debug("ERROR: Error when creating/removing shell layers.")

## Internal enum to easily access parameters for the moss shader in code without resorting to hardcoding strings into method calls
enum MossShaderParameters {
	SHELL_COLOUR,
	OBJECT_SCALE,
	SHELL_INDEX,
	SHELL_COUNT,
	SHELL_LENGTH,
	DENSITY,
	NOISE_MIN,
	NOISE_MAX,
	THICKNESS,
	ATTENUATION,
	OCCLUSION_BIAS,
	SHELL_DISTANCE_ATTENUATION,
	CURVATURE,
	DISPLACEMENT_STRENGTH,
}

