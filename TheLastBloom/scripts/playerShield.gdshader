shader_type canvas_item;

uniform vec4 shield_color : source_color = vec4(0.65, 0.75, 0.85, 1.0);
uniform float line_width : hint_range(0.0, 0.05) = 0.005;
uniform float glow_intensity : hint_range(1.0, 10.0) = 4.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 9;

void fragment() {
	vec2 center_uv = UV - vec2(0.5); // το κέντρο των UV στο κέντρο του sprite 
	float dist = length(center_uv); // απόσταση pixel από το κέντρο
	float radius = 0.48; // ακτίνα της ασπίδας
	float pulse = sin(TIME * pulse_speed) * 0.008;
	float final_radius = radius + pulse;
	float outer_edge = smoothstep(final_radius, final_radius - 0.001, dist);
	float inner_edge = smoothstep(final_radius - line_width, final_radius - line_width - 0.001, dist);
	float ring = outer_edge - inner_edge; // σχήμα ασπίδας
	vec3 final_color = shield_color.rgb * glow_intensity;
	float final_alpha = ring * shield_color.a;
	COLOR = vec4(final_color, final_alpha);
}
 