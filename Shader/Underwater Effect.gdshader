shader_type canvas_item;

uniform vec4 water_tint : source_color = vec4(0.1, 0.3, 0.5, 0.6);
uniform sampler2D noise_texture : repeat_enable;
uniform sampler2D screen_content: hint_screen_texture;

uniform vec2 wave_speed = vec2(0.02, 0.04);
uniform float wave_strength : hint_range(0.0, 0.08) = 0.015;
uniform float caustic_strength : hint_range(0.0, 1.5) = 0.3;
uniform vec2 caustic_speed = vec2(0.03, 0.05);

// Deep seabed specific uniforms
uniform float water_depth : hint_range(0.0, 1.0) = 0.8;
uniform vec4 deep_color : source_color = vec4(0.02, 0.1, 0.2, 0.9);
uniform float visibility_range : hint_range(0.1, 1.0) = 0.4;
uniform float sediment_density : hint_range(0.0, 0.5) = 0.2;
uniform float current_strength : hint_range(0.0, 0.1) = 0.03;

void fragment() {
    // Distance from center for radial depth effect
    vec2 center = vec2(0.5, 0.5);
    float distance_from_center = length(UV - center) * 2.0;
    
    // Create depth-based visibility falloff
    float depth_visibility = 1.0 - clamp(distance_from_center * visibility_range * water_depth, 0.0, 1.0);
    
    // Multi-layer current movement for deep water
    vec2 current_flow1 = vec2(sin(TIME * 0.3), cos(TIME * 0.2)) * current_strength;
    vec2 current_flow2 = vec2(cos(TIME * 0.4), sin(TIME * 0.5)) * current_strength * 0.7;
    
    // Slow, heavy wave movement for deep water
    vec2 wave_uv = UV + wave_speed * TIME + current_flow1;
    vec2 noise = texture(noise_texture, wave_uv).rg;
    noise = (noise - 0.5) * 2.0;
    
    // Reduced distortion for deep water stability
    vec2 distorted_screen_uv = SCREEN_UV + noise * wave_strength * depth_visibility;
    vec4 screen_color = texture(screen_content, distorted_screen_uv);
    
    // Deep water caustics (very faint, filtered sunlight)
    vec2 caustic_uv = UV * 2.0 + caustic_speed * TIME + current_flow2;
    float caustics = texture(noise_texture, caustic_uv).r;
    caustics = pow(caustics, 4.0) * depth_visibility; // More concentrated, fades with depth
    
    // Sediment particles floating in current
    vec2 sediment_uv = UV * 6.0 + TIME * vec2(0.01, -0.02) + current_flow1 * 2.0;
    float sediment = texture(noise_texture, sediment_uv).b;
    sediment = smoothstep(0.85, 0.95, sediment) * sediment_density;
    
    // Marine snow effect (organic particles falling)
    vec2 snow_uv = UV * 4.0 + TIME * vec2(0.005, 0.02);
    float marine_snow = texture(noise_texture, snow_uv).g;
    marine_snow = smoothstep(0.9, 0.98, marine_snow) * 0.1;
    
    // Apply deep water color mixing
    vec4 final_color = screen_color;
    
    // Heavy water tint for deep environment
    final_color.rgb = mix(final_color.rgb, water_tint.rgb, water_tint.a);
    
    // Distance-based deep color overlay
    final_color.rgb = mix(final_color.rgb, deep_color.rgb, 
                         deep_color.a * (1.0 - depth_visibility));
    
    // Very subtle caustics (filtered sunlight from far above)
    final_color.rgb += caustics * caustic_strength * vec3(0.4, 0.6, 0.8);
    
    // Add floating particles
    final_color.rgb += sediment * vec3(0.6, 0.5, 0.4); // Brownish sediment
    final_color.rgb += marine_snow * vec3(0.8, 0.8, 0.9); // Whitish organic matter
    
    // Deep water darkness and blue shift
    final_color.rgb *= mix(vec3(0.2, 0.4, 0.7), vec3(1.0), depth_visibility);
    
    COLOR = final_color;
}