shader_type canvas_item;

uniform vec4 water_tint : source_color = vec4(0.2, 0.6, 0.8, 0.3);
uniform sampler2D noise_texture : repeat_enable;
uniform sampler2D screen_content: hint_screen_texture;

uniform vec2 wave_speed = vec2(0.03, 0.07);
uniform float wave_strength : hint_range(0.0, 0.1) = 0.02;
uniform float caustic_strength : hint_range(0.0, 2.0) = 0.5;
uniform vec2 caustic_speed = vec2(0.05, 0.08);

void fragment() {
    // Create moving noise for waves
    vec2 wave_uv = UV + wave_speed * TIM
    vec2 noise = texture(noise_texture, wave_uv).rg;
    
    // Convert noise from [0,1] to [-1,1] for bidirectional distortion
    noise = (noise - 0.5) * 2.0;
    
    // Apply wave distortion to screen sampling
    vec2 distorted_screen_uv = SCREEN_UV + noise * wave_strength;
    vec4 screen_color = texture(screen_content, distorted_screen_uv);
    
    // Create caustic light patterns
    vec2 caustic_uv = UV * 3.0 + caustic_speed * TIME;
    float caustics = texture(noise_texture, caustic_uv).r;
    caustics = pow(caustics, 3.0); // Make caustics more concentrated
    
    // Apply water tint and caustics
    vec4 final_color = screen_color;
    final_color.rgb = mix(final_color.rgb, water_tint.rgb, water_tint.a);
    final_color.rgb += caustics * caustic_strength * vec3(0.8, 0.9, 1.0);
    
    COLOR = final_color;
}