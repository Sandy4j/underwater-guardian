shader_type canvas_item;

uniform float inner_radius : hint_range(0.0, 0.5) = 0.3;
uniform float outer_radius : hint_range(0.0, 0.5) = 0.5;
uniform vec4 ring_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    float ring = smoothstep(inner_radius - 0.02, inner_radius, dist) * 
                 (1.0 - smoothstep(outer_radius, outer_radius + 0.02, dist));
    
    COLOR = ring_color * ring;
}