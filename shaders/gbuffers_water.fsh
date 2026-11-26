#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;
uniform float frameTimeCounter;
uniform vec3 shadowLightPosition;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 waterViewPos;
in vec3 waterNormal;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	float ripple = sin(gl_FragCoord.x * 0.06 + frameTimeCounter * 1.2);
	color.rgb *= 1.0 + 0.03 * ripple;
	color *= texture(lightmap, lmcoord);
	color.rgb = mix(color.rgb, vec3(0.08, 0.72, 0.68), 0.35);
	color.a = 1.0;

	vec3 N = normalize(waterNormal);
	vec3 V = normalize(-waterViewPos);
	vec3 L = normalize(shadowLightPosition);
	vec3 H = normalize(L + V);
	float glint = pow(max(dot(N, H), 0.0), 96.0);
	color.rgb += vec3(1.0, 0.94, 0.72) * glint * 0.8;

	if (color.a < alphaTestRef) {
		discard;
	}
}