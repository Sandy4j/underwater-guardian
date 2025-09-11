shader_type canvas_item;

uniform vec4 deep_water_color : source_color = vec4(0.0, 0.1, 0.3, 1.0);
uniform vec4 shallow_water_color : source_color = vec4(0.0, 0.4, 0.7, 1.0);
uniform float wave_amplitude : hint_range(0.0, 100.0) = 20.0;
uniform float wave_frequency : hint_range(0.0, 0.1) = 0.02;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.5;
uniform float particle_density : hint_range(0.0, 0.02) = 0.005;
uniform float current_strength : hint_range(0.0, 1.0) = 0.3;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    float time = TIME;
    
    // Create water surface waves at top
    float wave = sin(uv.x * wave_frequency + time * wave_speed) * wave_amplitude;
    float surface_mask = smoothstep(0.0, 0.2, 1.0 - uv.y);
    
    // Gradient from shallow to deep water
    float depth_gradient = smoothstep(0.0, 1.0, uv.y);
    vec4 water_color = mix(shallow_water_color, deep_water_color, depth_gradient);
    
    // Add floating particles
    vec2 particle_uv = uv * 50.0;
    particle_uv.x += time * current_strength * 10.0;
    particle_uv.y += sin(time + uv.x * 5.0) * 2.0;
    
    float particle_noise = random(floor(particle_uv));
    float particles = step(1.0 - particle_density, particle_noise);
    particles *= smoothstep(0.0, 0.5, fract(particle_uv.x)) * smoothstep(1.0, 0.5, fract(particle_uv.x));
    particles *= smoothstep(0.0, 0.5, fract(particle_uv.y)) * smoothstep(1.0, 0.5, fract(particle_uv.y));
    
    // Combine effects
    vec4 final_color = water_color;
    final_color.rgb += particles * vec3(0.5, 0.7, 1.0) * 0.3;
    
    COLOR = final_color;
}