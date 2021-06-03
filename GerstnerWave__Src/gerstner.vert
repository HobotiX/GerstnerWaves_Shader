#version 330 compatibility

uniform float Timer; //0-1 in 10s
uniform bool uWaveA_OnOff, uWaveB_OnOff, uWaveC_OnOff, uWaveAnimation;
uniform float uWaveSpeed;
uniform float uWaveA_X, uWaveA_Y, uWaveA_Amp, uWaveA_Freq;
uniform float uWaveB_X, uWaveB_Y, uWaveB_Amp, uWaveB_Freq;
uniform float uWaveC_X, uWaveC_Y, uWaveC_Amp, uWaveC_Freq;
vec4 waveA = vec4(0., 0., 0., 0.);
vec4 waveB = vec4(0., 0., 0., 0.);
vec4 waveC = vec4(0., 0., 0., 0.);

out vec3 vNs;
out vec3 vEs;
out vec3 vMC;

const float PI = 3.14159265;
const float Y0 = 1.;

vec4
GerstnerWave (vec4 wave, vec3 p, inout vec3 t, inout vec3 n)
{
	float amp = wave.z;
	float freq = wave.w;
	float k = 2 * PI / freq;
	float c = sqrt(9.8 / k);
	vec2 d = normalize(wave.xy);
	// Set Animation ////////////////
	float vTime;
	if(uWaveAnimation)
		vTime = uWaveSpeed * Timer; //Continuous (with hickup)
	else
		vTime = uWaveSpeed * .5 * sin(2. * PI * Timer) + .5; //Washing Machine (no hickup)
	float f = k * (dot(d, p.xz) - c * vTime);
	float a = amp / k;
	// Set Surface ////////////////
	t += vec3(-d.x * d.x * (amp * sin(f)), d.x * (amp * cos(f)), -d.x * d.y * (amp * sin(f))); // Set Tangent
	n += vec3(-d.x * d.y * (amp * sin(f)), d.y * (amp * cos(f)), -d.y * d.y * (amp * sin(f))); // Set Normal
	// Return Vert ////////////////
	return vec4(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)), 1.);
}

void
main( )
{
	waveA = vec4(uWaveA_X, uWaveA_Y, uWaveA_Amp, uWaveA_Freq);
	waveB = vec4(uWaveB_X, uWaveB_Y, uWaveB_Amp, uWaveB_Freq);
	waveC = vec4(uWaveC_X, uWaveC_Y, uWaveC_Amp, uWaveC_Freq);

	vMC = gl_Vertex.xyz;
	vec3 tang = vec3(1., 0., 0.);
	vec3 norm = vec3(0., 0., 1.);
	vec4 newVertex = gl_Vertex;

	if (uWaveA_OnOff)
		newVertex += GerstnerWave(waveA, vMC, tang, norm);
	if (uWaveB_OnOff)
		newVertex += GerstnerWave(waveB, vMC, tang, norm);
	if (uWaveC_OnOff)
		newVertex += GerstnerWave(waveC, vMC, tang, norm);

	vec4 ECposition = gl_ModelViewMatrix * newVertex;
	vNs = normalize(cross(norm, tang));
	vEs = ECposition.xyz - vec3(0.,0.,0.);
  gl_Position = gl_ModelViewProjectionMatrix * newVertex;
}
