#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform float frameTimeCounter;

uniform mat4 gbufferProjectionInverse;
 uniform vec3 fogColor;
 uniform float far;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

in vec2 texcoord;

const float FOG_DENSITY = 3.5;


vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise2D(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(cell);
    float b = hash21(cell + vec2(1.0, 0.0));
    float c = hash21(cell + vec2(0.0, 1.0));
    float d = hash21(cell + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
  color = texture(colortex0, texcoord);

  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    vec3 ndc = vec3(texcoord * 2.0 - 1.0, 1.0);
    vec3 viewRay = projectAndDivide(gbufferProjectionInverse, ndc);
    vec3 ray = normalize(mat3(gbufferModelViewInverse) * viewRay);

    if (ray.y > 0.01) {
        float t = (180.0 - cameraPosition.y) / ray.y;
        if (t > 0.0) {
            vec3 cloudPos = cameraPosition + ray * t;
            vec2 cloudUv = cloudPos.xz * 0.012;
            vec2 wind = vec2(frameTimeCounter * 0.04, frameTimeCounter * 0.015);
            float broadNoise = noise2D(cloudUv + wind);
            float detailNoise = noise2D(cloudUv * 3.5 + wind * 1.6);
            float density = broadNoise * 0.78 + detailNoise * 0.22;
            float cloudMask = smoothstep(0.46, 0.60, density);
            float highlight = smoothstep(0.58, 0.78, density);

            vec3 shadowColor = vec3(0.62, 0.42, 0.55);
            vec3 sunlitColor = vec3(1.0, 0.72, 0.45);
            vec3 cloudColor = mix(shadowColor, sunlitColor, highlight);
            float cloudEdge = 4.0 * cloudMask * (1.0 - cloudMask);
            cloudColor = mix(cloudColor, vec3(1.0, 0.38, 0.62), cloudEdge * 0.8);

            color.rgb = mix(color.rgb, cloudColor, cloudMask);
        }
    }
    return;
}

  vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
  vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);

    float dist = length(viewPos) / far;
    float fogFactor = exp(-FOG_DENSITY * (1.0 - dist));

    vec3 peachFog = vec3(0.95, 0.62, 0.48);
    color.rgb = mix(color.rgb, pow(peachFog, vec3(2.2)), clamp(fogFactor, 0.0, 1.0));}