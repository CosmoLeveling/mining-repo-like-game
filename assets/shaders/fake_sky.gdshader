shader_type sky;
render_mode use_quarter_res_pass;



group_uniforms sky;
	uniform vec3 top_color : source_color = vec3( 0.1, 0.6, 1.0 );
	uniform vec3 bottom_color : source_color = vec3( 0.4, 0.8, 1.0 );


group_uniforms horizon;
	uniform vec3 horizon_color : source_color = vec3( 0.0, 0.7, 0.8 );
	uniform float horizon_blur : hint_range( 0.0, 1.0, 0.01 ) = 0.05;

group_uniforms sun; // First DirectionalLight3D will be the sun
	uniform vec3 sun_color : source_color = vec3( 10.0, 8.0, 1.0 );
	uniform float sun_size : hint_range( 0.01, 1.0 ) = 0.2;
	uniform float sun_blur : hint_range( 0.01, 20.0 ) = 10.0;

group_uniforms clouds;
	uniform vec3 clouds_edge_color : source_color = vec3( 0.8, 0.8, 0.98 );
	uniform vec3 clouds_main_color : source_color = vec3( 1.0, 1.0, 1.00 );
	uniform float clouds_speed : hint_range( 0.0, 20.0, 0.01 ) = 0.01;
	uniform float clouds_scale : hint_range( 0.0, 4.0, 0.01 ) = 1.0;
	uniform float clouds_cutoff : hint_range( 0.0, 1.0, 0.01 ) = 0.3;
	
	uniform float clouds_weight : hint_range( 0.0, 1.0, 0.01 ) = 0.0;
	uniform float clouds_blur : hint_range( 0.0, 1.0, 0.01 ) = 0.25;
	const mat2 m = mat2(vec2( 1.6, 1.2), vec2(-1.2, 1.6));


vec2 hash( vec2 p ) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}
float noise( in vec2 p ) {
	const float K1 = 0.366025404; // (sqrt(3)-1)/2;
	const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor(p + (p.x + p.y)*K1);
	vec2 a = p - i + (i.x + i.y) * K2;
	vec2 o = (a.x > a.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0 * K2;
	vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0 );
	vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
	return dot(n, vec3(70.0));
}
float fbm(vec2 n) {
	float total = 0.0, amplitude = 0.1;
	for (int i = 0; i < 7; i++) {
		total += noise(n) * amplitude;
		n = m * n;
		amplitude *= 0.4;
	}
	return total;
}
void sky()
{
	float time = TIME;
	vec2 _sky_uv = EYEDIR.xz / sqrt( EYEDIR.y );
	
	float _eyedir_y = abs( sin( EYEDIR.y * PI * 0.5 ));

	//SKYCOLOR
	vec3 _sky_color = mix(bottom_color, top_color, _eyedir_y );
	_sky_color = mix( _sky_color, vec3( 0.0 ), clamp(( 0.7 - clouds_cutoff ) * clouds_weight, 0.0, 1.0 ));
	COLOR = _sky_color;

	//HORIZON
	float _horizon_amount = 0.0;
	if( EYEDIR.y < 0.0 )
	{
		_horizon_amount = clamp( abs( EYEDIR.y ) / horizon_blur, 0.0, 1.0 );
		vec3 _horizon_color = mix( horizon_color, _sky_color, 0.9 );
		_horizon_color = mix( _horizon_color, vec3( 0.0 ), ( 1.0 - clouds_cutoff ) * clouds_weight * 0.7 );
		COLOR = mix( COLOR, _horizon_color, _horizon_amount );
	}
	//SUN
	float _sun_distance = 0.0;
	if( LIGHT0_ENABLED )
	{
		_sun_distance = distance( EYEDIR, LIGHT0_DIRECTION );
		// Bigger sun near the horizon
		float _sun_size = sun_size + cos( LIGHT0_DIRECTION.y * PI ) * sun_size * 0.25;
		// Finding sun disc and edge blur
		float _sun_amount = clamp(( 1.0 - _sun_distance / _sun_size ) / sun_blur, 0.0, 1.0 );
		if( _sun_amount > 0.0 )
		{
			vec3 _sun_color = sun_color;
			_sun_amount *= 1.0 - _horizon_amount;
			// Leveling the "glow" in color
			if( _sun_color.r > 1.0 || _sun_color.g > 1.0 || _sun_color.b > 1.0 )
				_sun_color *= _sun_amount;
			COLOR = mix( COLOR, _sun_color, _sun_amount );
		}
	}
	//CLOUDS
	if( EYEDIR.y > 0.0 )
	{
		vec3 normal = normalize(EYEDIR);
		
		
		vec3 plane_intersect = normal / (normal.y + clouds_cutoff);
		
		vec2 p = plane_intersect.xz;
		p.y *= -1.0;
		vec2 uv = p;
		
		time = time * clouds_speed;
		float q = fbm(uv * clouds_scale * 0.5);
		
		//ridged noise shape
		float r = 0.0;
		time = TIME * clouds_speed * 0.3;
		uv *= clouds_scale;
		uv -= q - time;
		float weight = 0.8;
		for(int i = 0; i < 8; i++){
			r += abs(weight*noise( uv ));
			uv = m*uv + time;
			weight *= 0.7;
		}
		
		//noise shape
		float f = 0.0;
		time = TIME * clouds_speed * 0.4;
		uv = p;
		uv *= clouds_scale;
		uv -= q - time;
		weight = 0.7;
		for(int i = 0; i < 8; i++){
			f += weight*noise( uv );
			uv = m*uv + time;
			weight *= 0.6;
		}
		
		f *= r + f;
		
		//noise colour
		float c = 0.0;
		time = TIME * clouds_speed * 2.0;
		uv = p;
		uv *= clouds_scale * 1.5;
		uv -= q - time;
		weight = 0.4;
		for(int i = 0; i < 7; i++){
			c += weight*noise( uv );
			uv = m*uv + time;
			weight *= 0.6;
		}
		
		//noise ridge colour
		float c1 = 0.0;
		time = TIME * clouds_speed * 5.0;
		uv = p;
		uv *= clouds_scale * 3.0;
		uv -= q - time;
		weight = 0.4;
		for (int i = 0; i < 7; i++){
			c1 += abs(weight*noise( uv ));
			uv = m*uv + time;
			weight *= 0.6;
		}
		
		c += c1;
		
		
		
		
		float _clouds_amount = clamp( c, 0.0, 1.0 );
		_clouds_amount *= clamp( abs( EYEDIR.y ) / clouds_blur, 0.0, 1.0 );
		vec3 skycolour = COLOR;
		vec3 clouds = mix(clouds_edge_color,  clouds_main_color , pow( _clouds_amount,2.0) );
		COLOR = mix( skycolour, clouds , _clouds_amount);
	}
}