shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 0.8, 0.0, 1.0);
uniform float speed : hint_range(0.1, 10.0) = 2.0;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	float timer = abs(sin(TIME * speed));
	vec3 mixed_color = mix(COLOR.rgb, flash_color.rgb, timer);
	COLOR = vec4(mixed_color, current_color.a);
}