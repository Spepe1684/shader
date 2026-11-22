#version 330 compatibility

// Do note: #include is a "pre-processor directive". These directives are processed *before* your GPU compiles your shaders.
// Pre-processor directives don't need semi-colons at the end!
#include "/lib/shadowDistort.glsl"

out vec2 texcoord;
out vec4 glcolor;

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  glcolor = gl_Color;
  gl_Position = ftransform();
}