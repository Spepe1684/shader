#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D lightmap;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;


 /* RENDERTARGETS: 0,1,2 */
 layout(location = 0) out vec4 color;
 layout(location = 1) out vec4 lightLevelData;
 layout(location = 2) out vec4 encodedNormal;


void main() {
	color = texture(gtexture, texcoord) * glcolor;

	float greenMask = smoothstep(
    0.02, 0.18,
    color.g - max(color.r, color.b)
	);
	color.rgb = mix(color.rgb, vec3(0.60, 0.72, 0.48), greenMask * 0.30);

	color *= texture(lightmap, lmcoord);

	lightLevelData = vec4(lmcoord, 0.0, 1.0); // this will write to buffer #1, as we defined above!
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);

	if (color.a < alphaTestRef) {
		discard;
	}
}