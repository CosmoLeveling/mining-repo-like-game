shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture;

void fragment(){
	ALBEDO = texture(screen_texture,vec2(UV.x,UV.y)).rgb;
}