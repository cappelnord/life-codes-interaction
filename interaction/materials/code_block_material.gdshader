shader_type canvas_item;

uniform vec3 hsv;
uniform vec3 rgb_add;

const float THREESIXTY_DEG = 1.0;
const float SIXTY_DEG = 0.166666667;

vec3 rgb2hsv(vec3 inc) {

    inc = clamp(inc, 0.0, 1.0);

	float r = inc.r;
	float g = inc.g;
	float b = inc.b;

	float maxv = max(r, max(g, b));
	float minv = min(r, min(g, b));
	
	float h = 0.0;
	float s = 0.0;
	float v = maxv;

	float maxmindif = (maxv-minv);

	if(maxv != 0.0) {
		s = maxmindif / maxv;
	}

	if(maxv == r) {
		h = ((g-b) / maxmindif);
	} else if (maxv == g) {
		h = 2.0 + ((b-r) / maxmindif);
	} else if (maxv == b) {
		h = 4.0 + ((r-g) / maxmindif);
	}

	h *= SIXTY_DEG;

	if(h < 0.0) {
		h += THREESIXTY_DEG;
	}

	return vec3(h, s, v);
}

vec3 hsv2rgb(vec3 inc) {

    inc = clamp(inc, 0.0, 1.0);

	vec3 outc;
	float h = inc.r;
	float s = inc.g;
	float v = inc.b;
	
	int hi = int((h * 6.0));
	float f = (h*6.0) - float(hi);

	float p = v * (1.0 - s);
	float q = v * (1.0 - s * f);
	float t = v * (1.0 - s * (1.0 - f));

	outc = vec3(v, t, p);

	if(hi == 1) outc = vec3(q, v, p);
	if(hi == 2) outc = vec3(p, v, t);
	if(hi == 3) outc = vec3(p, q, v);
	if(hi == 4) outc = vec3(t, p, v);
	if(hi == 5) outc = vec3(v, p, q);

	return outc;
}


void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 cHSV = rgb2hsv(c.rgb);
	COLOR = vec4(hsv2rgb(vec3(hsv.x, cHSV.y * hsv.y, cHSV.z * hsv.z)) + rgb_add, c.a);
}
