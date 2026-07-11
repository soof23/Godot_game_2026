shader_type canvas_item;

uniform float fill_amount : hint_range(0.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float pulse = (sin(TIME * 4.0) * 0.15) + 1.0;
	vec3 glow = tex_color.rgb * fill_amount * pulse * 2.5;
	COLOR = vec4(tex_color.rgb + (glow * tex_color.a), tex_color.a);
}
