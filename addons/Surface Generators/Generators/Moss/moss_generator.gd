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

@export var _object_scale: Vector2:
	set(new_object_scale):
		_object_scale = new_object_scale
		
@export var _shell_index: int  # This is the current shell layer being operated on, it ranges from 0 -> _ShellCount 
@export var _shell_count: int = 8 # This is the total number of shells, useful for normalizing the shell index
@export var _shell_length: float # This is the amount of distance that the shells cover, if this is 1 then the shells will span across 1 world space unit
@export var _density: float  # This is the density of the strands, used for initializing the noise
@export var _noise_min: float
@export var _noise_max: float # This is the range of possible hair lengths, which the hash then interpolates between 
@export var _thickness: float # This is the thickness of the hair strand
@export var _attenuation: float # This is the exponent on the shell height for lighting calculations to fake ambient occlusion (the lack of ambient light)
@export var _occlusion_bias: float # This is an additive constant on the ambient occlusion in order to make the lighting less harsh and maybe kind of fake in-scattering
@export var _shell_distance_attenuation: float # This is the exponent on determining how far to push the shell outwards, which biases shells downwards or upwards towards the minimum/maximum distance covered


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
		var moss_shader_material: ShaderMaterial = ShaderMaterial.new()
		moss_shader_material.shader = surface_shader
		# Set the variables for the shader
		
		# Finish shell creation by adding as child to moss generator.
		add_child(mesh_shell)
		mesh_shell.set_owner(self)


func _update_settings(value: SurfaceSettings) -> void:
	print("Settings updated")


## Used to find the first child with a mesh. Does not return multiple messes.
## Can not search further than the children in node
#func find_node_with_mesh(node: Node) -> Node:
#	for child in node.get_children():
#		if(child is MeshInstance3D):
#			return child
#	return null
