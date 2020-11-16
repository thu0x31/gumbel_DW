vec3 random3(vec3 c) {
    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r-0.5;
}

float snoise(vec3 p) {
    const float F3 =  0.3333333;
    const float G3 =  0.1666667;

    vec3 s = floor(p + dot(p, vec3(F3)));
    vec3 x = p - s + dot(s, vec3(G3));

    vec3 e = step(vec3(0.0), x - x.yzx);
    vec3 i1 = e*(1.0 - e.zxy);
    vec3 i2 = 1.0 - e.zxy*(1.0 - e);

    vec3 x1 = x - i1 + G3;
    vec3 x2 = x - i2 + 2.0*G3;
    vec3 x3 = x - 1.0 + 3.0*G3;

    vec4 w, d;

    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);

    w = max(0.6 - w, 0.0);

    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);

    w *= w;
    w *= w;
    d *= w;

    return dot(d, vec4(52.0));
}

vec3 normalNoise(vec2 _st, float _zoom, float _speed){
	vec2 v1 = _st;
	vec2 v2 = _st;
	vec2 v3 = _st;
	float expon = pow(10.0, _zoom*2.0);
	v1 /= 1.0*expon;
	v2 /= 0.62*expon;
	v3 /= 0.83*expon;
	float n = iTime * _speed;
	float nr = (snoise(vec3(v1, n)) + snoise(vec3(v2, n)) + snoise(vec3(v3, n))) / 6.0 + 0.5;
	n = iTime * _speed + 1000.0;
	float ng = (snoise(vec3(v1, n)) + snoise(vec3(v2, n)) + snoise(vec3(v3, n))) / 6.0 + .5;
	return vec3(nr,ng,0.5);
}

#define NUM_OCTAVES 6
vec3 fbm(vec2 _st, float zoom, vec2 shift, float shiftSpeed, float rad) {
    vec3 v = vec3(0.0);
    float a = 0.5;
    // vec2 shift = vec2(100.);
    mat2 rot = mat2(cos(rad), sin(rad), -sin(rad), cos(rad));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * normalNoise(_st * 5. , zoom, shiftSpeed);
        _st = rot * _st * 2.0 + shift;
        a *= .5;
    }
    return v;
}

vec3 gumbelNoise(vec3 vec) {
    return -log(-log(vec));
}

vec3 pattern(vec2 _st) {
    vec3 fbm1 = fbm(_st, .12, vec2(100.), 0.01, 1.);

    vec3 fbm2 = gumbelNoise(fbm(
            _st + fbm1.xy,
            fbm1.z * .9,
            vec2(fbm1.x, 100.),
            fbm1.z * 0.059,
            fbm1.x * 0.07)
        );

    vec3 fbm3 = gumbelNoise(fbm(
        _st + fbm2.xy,
            fbm2.z * .8,
            vec2(100., fbm2.x),
            fbm2.z * 0.058,
            fbm2.x * 0.007)
        );

    return fbm3;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 st = (fragCoord.xy * 2. - iResolution.xy) / min(iResolution.x, iResolution.y);
    fragColor = vec4(pattern(st), 1.0);
}