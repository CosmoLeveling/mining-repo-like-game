shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_disabled,shadows_disabled;

varying vec3 world_normal;

void vertex() {
	world_normal = NORMAL;
}

void fragment() {
	ALBEDO = world_normal.rgb;
}