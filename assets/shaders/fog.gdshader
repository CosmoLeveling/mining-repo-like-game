shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 fog_color : source_color = vec4(0.6, 0.6, 0.6, 1.0);
uniform float fade_distance : hint_range(0.1, 20.0) = 4.0;
uniform vec3 camera_position; // <-- we set this from script

void fragment() {
    vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float dist = distance(world_position, camera_position);

    float alpha = clamp((dist - fade_distance * 0.5) / fade_distance, 0.0, 1.0);
    ALBEDO = fog_color.rgb;
    ALPHA = alpha;
}