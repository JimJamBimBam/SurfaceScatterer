@tool
class_name MossGenerator extends SurfaceGenerator3D

# TODO: Have a global variable that can control all moss generators sheel count. (quality versus speed)
## Reference to the mesh that the moss will draw onto
# TODO: Have way of telling if values are not defaults by storing default values at start
# then comparing them when global settings is updated and refusing to update the value if it has changed from the default
#const MossShader: Shader = preload("moss_shader.gdshader")
#const MossSettings: Resource = preload("moss_settings.gd")
#var MOSS_GLOBAL_SETTINGS_DOCK: = preload("moss_global_settings_dock.gd")

#var _mesh: MeshInstance3D

@export var _shell_colour: Color = Color.WHITE

@export var _object_scale: Vector2 = Vector2.ONE:
	set(new_object_scale):
		_object_scale = new_object_scale
		if moss_shader_material != null:
			moss_shader_material.set_shader_parameter("object_scale", new_object_scale)
@export var _shell_index: int:  # This is the current shell layer being operated on, it ranges from 0 -> _ShellCount 
	set(new_shell_index):
		_shell_index = new_shell_index
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("shell_index", new_shell_index)
@export var _shell_count: int = 8: # This is the total number of shells, useful for normalizing the shell index
	set(new_shell_count):
		_shell_count = new_shell_count
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("shell_count", new_shell_count)
@export var _shell_length: float = 1.0: # This is the amount of distance that the shells cover, if this is 1 then the shells will span across 1 world space unit
	set(new_shell_length):
		_shell_length = new_shell_length
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("shell_length", new_shell_length)
@export var _density: float = 100.0:  # This is the density of the strands, used for initializing the noise
	set(new_density):
		_density = new_density
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("density", new_density)
@export var _noise_min: float = 0.0:
	set(new_noise_min):
		_noise_min = new_noise_min
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("noise_min", new_noise_min)
@export var _noise_max: float = 0.9: # This is the range of possible hair lengths, which the hash then interpolates between 
	set(new_noise_max):
		_noise_max = new_noise_max
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("noise_max", new_noise_max)
@export var _thickness: float = 0.2: # This is the thickness of the hair strand
	set(new_thickness):
		_thickness = new_thickness
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("thickness", new_thickness)
@export var _attenuation: float = 0.1: # This is the exponent on the shell height for lighting calculations to fake ambient occlusion (the lack of ambient light)
	set(new_attenuation):
		_attenuation = new_attenuation
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("attenuation", new_attenuation)
@export var _occlusion_bias: float = 0.1: # This is an additive constant on the ambient occlusion in order to make the lighting less harsh and maybe kind of fake in-scattering
	set(new_occlusion_bias):
		_occlusion_bias = new_occlusion_bias
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("occlusion_bias", new_occlusion_bias)
@export var _shell_distance_attenuation: float = 0.1: # This is the exponent on determining how far to push the shell outwards, which biases shells downwards or upwards towards the minimum/maximum distance covered
	set(new_shell_distance_attenuation):
		_shell_distance_attenuation = new_shell_distance_attenuation
		if moss_shader_material:
			moss_shader_material.set_shader_parameter("shell_distance_attenuation", new_shell_distance_attenuation)

@export var moss_shader_material: ShaderMaterial

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
		var mesh_shell = attached_mesh.duplicate()
		#Apply name for better visiblity in editor
		mesh_shell.name = "mesh_shell_ %02d" % i
		
		# Apply the shader material to the mesh shells
		moss_shader_material = ShaderMaterial.new()
		moss_shader_material.shader = surface_shader
		# Set the variables for the shader
		
		# Finish shell creation by adding as child to moss generator.
		add_child(mesh_shell)
		mesh_shell.set_owner(self)


func _update_settings(value: SurfaceSettings) -> ShaderMaterial:
	print("Settings updated")
	# Want to return the shader material passed in but with new settings
	return ShaderMaterial.new()


