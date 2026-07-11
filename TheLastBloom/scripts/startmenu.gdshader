shader_type canvas_item;

// χρώματα για το εφέ μετάβασης  
uniform vec4 target_color : source_color = vec4(0.6, 0.2, 0.8, 1.0); // μωβ
uniform vec4 base_color : source_color = vec4(0.2, 0.2, 0.2, 1.0);   // γκρι
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // λευκή λάμψη

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float wave_intensity : hint_range(0.0, 0.1) = 0.02; 
uniform float shine_progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 original_color = COLOR; 
	vec4 tex_color = texture(TEXTURE, UV);
	
	float wave = sin(UV.y * 10.0) * wave_intensity; // κυματιστή κίνηση στον άξονα x
	float current_x = UV.x + wave; // εφαρμογή κυματισμού
	
	float mask = smoothstep(progress - 0.05, progress + 0.05, UV.x); // για τη μετάβαση χρωμάτων, smoothstep για σβήσιμο
	float shine_width = 0.05;
	float shine_mask = smoothstep(shine_progress - shine_width, shine_progress, current_x) - smoothstep(shine_progress, shine_progress + shine_width, current_x);
	vec3 mixed_color = mix(target_color.rgb, base_color.rgb, mask); // mix μωβ και γκρι με βάση τη μάσκα
	vec3 final_text_color = mixed_color + (shine_color.rgb * shine_mask); // προσθήκη λαμψης
	
	float brightness = length(original_color.rgb);
	float is_outline = step(brightness, 0.1); // Αν η φωτεινότητα χαμηλή, είναι outline
	
	vec3 final_output = mix(final_text_color, original_color.rgb, is_outline); // Αν είναι outline κρατάει το original_color
	COLOR = vec4(final_output, tex_color.a);
}