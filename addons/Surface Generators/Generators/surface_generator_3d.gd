@tool
class_name SurfaceGenerator3D extends Node3D

## Abstract class that handles surface generation for 3D Nodes

## The shader that the extended class will reference when generating a surface.
@export var surface_shader: Shader:
	get: return surface_shader
	set(new_surface_shader):
		surface_shader = new_surface_shader
		
		if(surface_material == null):
			surface_material = ShaderMaterial.new()
		
		surface_material.shader = new_surface_shader

## Used with the surface_shader to be able to draw the effect onto objects.
var surface_material: ShaderMaterial = ShaderMaterial.new()


## The mesh instance that the generator will use to generate a shell tuexture
## layers to.
var attached_mesh: MeshInstance3D:
	get: return attached_mesh
	set(new_mesh):
		attached_mesh = new_mesh
		# Must recreate the surface with the new mesh
		_generate_surface()

func _ready() -> void:
	attached_mesh = NodeMethods.get_first_instance_of_type_in_children(MeshInstance3D, get_parent(), true)
	assert(attached_mesh != null, "%s does not have any children that extend MeshInstance3D./
	 Consider removing generator node as this not doing anything." % get_parent())

## Virtural method that must be overridden if the user wishes to use it.
## Method is used to return a boolean that checks to see if the generator has
## run once already, either from a previous session or during the current session.
func _has_generator_run() -> bool:
	return false


## Override to provide different functionality for how a surface shader will
## generate on a mesh object
func _generate_surface():
	pass

## Override to provide different functionality for how the user will apply
## new settings to the specific generator implementation
func _update_settings(new_settings: SurfaceSettings):
	pass
