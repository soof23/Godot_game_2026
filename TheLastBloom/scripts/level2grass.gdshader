shader_type canvas_item;

void light() {
	vec3 light_color = LIGHT_COLOR.rgb; // χρώμα του φωτός
	float intensity = LIGHT_ENERGY;
	LIGHT = vec4(light_color * intensity, LIGHT.a);
}