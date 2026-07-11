shader_type canvas_item;

uniform float pulse_speed : hint_range(0.0, 10.0) = 2.5;
uniform float pulse_intensity : hint_range(0.0, 0.2) = 0.05;

void vertex() {
	float pulse = sin(TIME * pulse_speed) * pulse_intensity;
	VERTEX += VERTEX * pulse;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float shine = sin(TIME * pulse_speed) * 0.1 + 0.1;
	color.rgb += shine * color.a; //λάμψη εκτός από τα διάφανα pixel 
	COLOR = color;
} 