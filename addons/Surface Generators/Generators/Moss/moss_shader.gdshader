shader_type spatial;
render_mode cull_disabled, diffuse_toon, specular_toon;

#include "res://addons/Surface Generators/Generators/shader_methods.gdshaderinc"

uniform vec2 object_scale;
uniform int shell_index; // This is the current shell layer being operated on, it ranges from 0 -> _ShellCount 
uniform int shell_count;  // This is the total number of shells, useful for normalizing the shell index
uniform float shell_length; // This is the amount of distance that the shells cover, if this is 1 then the shells will span across 1 world space unit
uniform float density;  // This is the density of the strands, used for initializing the noise
uniform float noise_min;
uniform float noise_max; // This is the range of possible hair lengths, which the hash then interpolates between 
uniform float thickness; // This is the thickness of the hair strand
uniform float attenuation; // This is the exponent on the shell height for lighting calculations to fake ambient occlusion (the lack of ambient light)
uniform float occlusion_bias; // This is an additive constant on the ambient occlusion in order to make the lighting less harsh and maybe kind of fake in-scattering
uniform float shell_distance_attenuation; // This is the exponent on determining how far to push the shell outwards, which biases shells downwards or upwards towards the minimum/maximum distance covered

group_uniforms edge_noise;
uniform sampler2D gradient_noise;
uniform sampler2D edge_noise;

group_uniforms physics;
uniform float curvature; // This is the exponent on the physics displacement attenuation, a higher value controls how stiff the hair is
uniform float displacement_strength; // The strength of the displacement (very complicated)
uniform vec3 shell_colour: source_color; // The color of the shells (very complicated)
uniform vec3 shell_direction; // The direction the shells are going to point towards, this is updated by the CPU each frame based on user input/movement


global uniform vec3 HAIR_DISPLACEMENT_DIRECTION;

void vertex()
{
	//Find the height the shell should be based on its index position and the total number of shells.
	//Value supplied by external script.
	//==========================================//
	float shell_height = float(shell_index) / float(shell_count);
	shell_height = pow(shell_height, shell_distance_attenuation);
	VERTEX.xyz += NORMAL.xyz * shell_length * shell_height;
	
	float k = pow(shell_height, curvature);
	VERTEX.xyz += HAIR_DISPLACEMENT_DIRECTION * k * displacement_strength;
	//==========================================//
}


void fragment()
{
	vec2 new_UV = UV * density * object_scale;
	vec2 local_UV = fract(new_UV) * 2.0 - 1.0;
	float local_distance_from_center = length(local_UV);
	
	uint x = uint(int(new_UV.x));
	uint y = uint(int(new_UV.y));
	uint seed = x + 100u * y + 100u * 10u;
	float v = lerp(noise_min, noise_max, hash(seed));
	float h = float(shell_index) / float(shell_count);
	bool should_discard = (local_distance_from_center) > (thickness * pow(v, 2.0 / curvature) - (pow(h, curvature)));
	
	if(should_discard && shell_index >= 0)
	{
		discard;
	}
	
	//AO calculation
	float ambient_occulusion = pow(h, attenuation);
	ambient_occulusion += occlusion_bias;
	ambient_occulusion = clamp(ambient_occulusion, 0.0, 1.0);
	ALBEDO = vec3(shell_colour * ambient_occulusion);
	
	vec4 color = texture(gradient_noise, UV);
	ALBEDO = vec3(color.x, color.y, color.z);
}