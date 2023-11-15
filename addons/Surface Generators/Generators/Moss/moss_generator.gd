@tool
class_name MossGenerator extends SurfaceGenerator3D
## Surface generation class that can take any 3D mesh object that it is a child of and
## using Shell Texturing, create a textured surface on top of the original mesh.

# TODO: Have a global variable that can control all moss generators sheel count. (quality versus speed)
# Reference to the mesh that the moss will draw onto
# TODO: Have way of telling if values are not defaults by storing default values at start
# then comparing them when global settings is updated and refusing to update the value if it has changed from the default

var moss_shader: Shader = preload("res://addons/Surface Generators/Generators/Moss/moss_shader.gdshader")


## Special variable. Keeps track of the current index layer a mesh layer is on.
#var _shell_index: int:  # This is the current shell layer being operated on, it ranges from 0 -> _ShellCount 
#	set(new_shell_index):
#		_shell_index = new_shell_index
#		if is_node_ready():
#			pass
			#_update_setting(MossShaderParameters.SHELL_INDEX, new_shell_index)

@export var _shell_colour: Color = Color.WHITE:
	set(new_shell_colour):
		_shell_colour = new_shell_colour
		if is_node_ready():
			_update_setting(ShellShaderParameters.SHELL_COLOUR, new_shell_colour, _shells)
			
@export var _object_scale: Vector2 = Vector2.ONE:
	set(new_object_scale):
		_object_scale = new_object_scale
		if is_node_ready():
			_update_setting(ShellShaderParameters.OBJECT_SCALE, new_object_scale, _shells)

@export var _shell_count: int = 32: # This is the total number of shells, useful for normalizing the shell index
	set(new_shell_count):
		_shell_count = new_shell_count
		if is_node_ready():
			_update_number_of_shell_layers()
			
@export var _shell_length: float = 1.0: # This is the amount of distance that the shells cover, if this is 1 then the shells will span across 1 world space unit
	set(new_shell_length):
		_shell_length = new_shell_length
		if is_node_ready():
			_update_setting(ShellShaderParameters.SHELL_LENGTH, new_shell_length, _shells)
			
@export var _density: float = 100.0:  # This is the density of the strands, used for initializing the noise
	set(new_density):
		_density = new_density
		if is_node_ready():
			_update_setting(ShellShaderParameters.DENSITY, new_density, _shells)
			
@export var _noise_min: float = 0.0:
	set(new_noise_min):
		_noise_min = new_noise_min
		if is_node_ready():
			_update_setting(ShellShaderParameters.NOISE_MIN, new_noise_min, _shells)
			
@export var _noise_max: float = 0.9: # This is the range of possible hair lengths, which the hash then interpolates between 
	set(new_noise_max):
		_noise_max = new_noise_max
		if is_node_ready():
			_update_setting(ShellShaderParameters.NOISE_MAX, new_noise_max, _shells)
			
@export var _thickness: float = 0.2: # This is the thickness of the hair strand
	set(new_thickness):
		_thickness = new_thickness
		if is_node_ready():
			_update_setting(ShellShaderParameters.THICKNESS, new_thickness, _shells)
			
@export var _attenuation: float = 0.1: # This is the exponent on the shell height for lighting calculations to fake ambient occlusion (the lack of ambient light)
	set(new_attenuation):
		_attenuation = new_attenuation
		if is_node_ready():
			_update_setting(ShellShaderParameters.ATTENUATION, new_attenuation, _shells)
			
@export var _occlusion_bias: float = 0.1: # This is an additive constant on the ambient occlusion in order to make the lighting less harsh and maybe kind of fake in-scattering
	set(new_occlusion_bias):
		_occlusion_bias = new_occlusion_bias
		if is_node_ready():
			_update_setting(ShellShaderParameters.OCCLUSION_BIAS, new_occlusion_bias, _shells)
			
@export var _shell_distance_attenuation: float = 0.1: # This is the exponent on determining how far to push the shell outwards, which biases shells downwards or upwards towards the minimum/maximum distance covered
	set(new_shell_distance_attenuation):
		_shell_distance_attenuation = new_shell_distance_attenuation
		if is_node_ready():
			_update_setting(ShellShaderParameters.SHELL_DISTANCE_ATTENUATION, new_shell_distance_attenuation, _shells)

@export_category("Physics Settings")
@export var _stiffness: float:
	set(new_stiffness):
		_stiffness = new_stiffness
		if is_node_ready():
			_update_setting(ShellShaderParameters.CURVATURE, new_stiffness, _shells)
			
@export var _displacement_strength: float:
	set(new_displacement_strength):
		_displacement_strength = new_displacement_strength
		if is_node_ready():
			_update_setting(ShellShaderParameters.DISPLACEMENT_STRENGTH, new_displacement_strength, _shells)


## Keeps a reference to all the shells. Makes it easier to change settings.
var _shells: Array[MeshInstance3D] = []


func _ready() -> void:
	super() # Super calls base _ready() to set up a couple things that all Generators should do such as getting the mesh of the object that we wish to draw layers onto.

	# Create the surface in which the shader will be drawn on.
	_generate_surface()
	print("%s, the mesh attached to %s" % [self.name, attached_mesh.name])
	
	# With the surface created, update the settings of the surface materials
#	_update_settings_for_all_shader_instances(_shells, SurfaceSettings.new())


func _has_generator_run() -> bool:
	return get_child_count(true) > 0


## Used to create the mesh copies that will serve as the shells of the surface generator.
func _generate_surface():
	# Make sure that we have a mesh to generate a surface on first.
	if attached_mesh == null:
		return

	# Generate mesh shells for the moss material shader,
	# using copies of the base mesh to do this.
	for i in _shell_count:
		var mesh_shell: MeshInstance3D = _create_shell_layer(i)

		# Finish shell creation by adding as child to moss generator.
		add_child(mesh_shell)
		
		# Keep track of all the shells by storing it in the array.
		_shells.push_back(mesh_shell)

## Function that creates a new shell layer (mesh + shader) based on current index.
## Shell positions are based on what number index it has.
func _create_shell_layer(index: int) -> MeshInstance3D:
	var new_mesh_shell: MeshInstance3D = attached_mesh.duplicate()
	#Apply name for better visiblity in editor
	new_mesh_shell.name = "mesh_shell_ %02d" % index
	
	# Set up shader material for the given shell
	var material: ShaderMaterial = surface_material.duplicate()
	material.shader = moss_shader
	var index_parameter_as_string: String = ShellShaderParameters.keys()[ShellShaderParameters.SHELL_INDEX].to_lower()
	material.set_shader_parameter(index_parameter_as_string, index)
	
	# Apply the shader material to the mesh shells
	new_mesh_shell.set_surface_override_material(0, material)
	return new_mesh_shell


## Updates a single parameter in all shells based on the ShellShaderParameter
func _update_setting(parameter_to_change: ShellShaderParameters, value: Variant, nodes_with_shader: Array[MeshInstance3D]) -> void:
#	print("Settings updated")
	var parameter_as_string: String = ShellShaderParameters.keys()[parameter_to_change].to_lower()
#	print(parameter_as_string)
	
	for node in nodes_with_shader:
		_set_material_parameter_in(node, parameter_as_string, value)


# Not sure if needed since variables can only change one at a time anyway.
func _update_settings_for_all_shader_instances(nodes_with_shader: Array[MeshInstance3D], new_surface_settings: SurfaceSettings):
	if !new_surface_settings.is_class("MossSettings"):
		print("ERROR: %s is not of type, MossSettings" % new_surface_settings)
		return

	# Cast new_moss_settings to MossSettings to get variables in code editor
	var new_moss_settings: MossSettings = new_surface_settings as MossSettings
	
	for node in nodes_with_shader:
		var material_on_node: ShaderMaterial = node.get_surface_override_material(0) as ShaderMaterial
		# Ignore if material or shader on material does not exist
		if(material_on_node == null || material_on_node.shader == null): continue
		
		if material_on_node.shader.resource_path != moss_shader.resource_path:
			# No. Ignore the material, it is not a moss shader. We can't change it's settings.
			continue
		else:
			new_surface_settings = new_surface_settings as MossSettings


func _set_material_parameter_in(mesh_instance_node: MeshInstance3D, parameter_name: String, value: Variant):
	var local_material: ShaderMaterial = mesh_instance_node.get_surface_override_material(0) as ShaderMaterial
	# Ignore if material or shader on material does not exist
	if(local_material == null || local_material.shader == null):
		return
		
	if local_material.shader.resource_path != moss_shader.resource_path:
		# No. Ignore the material, it is not a moss shader. We can't change it's settings.
		return
	else:
		local_material.set_shader_parameter(parameter_name, value)


# TODO: Refactor so that changes greater than one are taken into account.n
## Updates the number of shells in the mesh shader by the difference in the number of shells and the _shell_count
func _update_number_of_shell_layers() -> void:
	# Check to see if number of shells is larger or smaller than shell_count.
	var match_check: int = signi(_shells.size() - _shell_count)
	var delta: int = absi(_shells.size() - _shell_count)
	
	print(match_check)
	match match_check:
		# Yes. We need more layers. Create one.
		-1:
			for i in delta:
				var new_shell: MeshInstance3D = _create_shell_layer(_shells.size())
				_shells.push_back(new_shell)
		#No. We need less layers. Remove one.
		1:
			var shell_to_remove: MeshInstance3D = _shells.pop_back()
			if shell_to_remove: # Check incase the shell_count is <= 0 and pop_back returns null.
				shell_to_remove.queue_free()
		_:
			print_debug("ERROR: Error when creating/removing shell layers.")
