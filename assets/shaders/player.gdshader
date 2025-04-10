	shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,filter_linear_mipmap;

uniform float steps = 4.0;

float posterize(float val, float level)
{
	return round(val * level)/level;
}

vec3 rgb2hsv(vec3 c)
{
	vec4 k = vec4(0.0,-1.0/3.0,2.0/3.0,-1.0);
	vec4 p = mix(vec4(c.bg,k.wz),vec4(c.gb,k.xy),step(c.b,c.g));
	vec4 q = mix(vec4(p.xyw,c.r),vec4(c.r,p.yzx),step(p.x,c.r));

	float d = q.x - min(q.w,q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z+(q.w-q.y)/(6.0 * d+e)),d/(q.x+e),q.x);
}
vec3 hsv2rgb(vec3 c)
{
	vec4 k = vec4(1.0,2.0/3.0,1.0/3.0,3.0);
	vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
	return c.z * mix(k.xxx, clamp(p-k.xxx,0.0,1.0),c.y);
}

void fragment(){
	vec3 hsv = rgb2hsv(texture(SCREEN_TEXTURE,SCREEN_UV).rgb);
	float color_h = posterize(hsv.r,steps);
	float color_s = posterize(hsv.g,steps);
	float color_v = posterize(hsv.b,steps);
	vec3 new_color = hsv2rgb(vec3(color_h,color_s,color_v));
	COLOR.rgb = new_color;
}