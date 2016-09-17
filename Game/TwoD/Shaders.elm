module Game.TwoD.Shaders exposing (..)

import WebGL exposing (Shader, Texture)
import Game.TwoD.Shapes exposing (Vertex)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)


vertTexturedRect : Shader Vertex { u | transform : Mat4, cameraProj : Mat4 } { vcoord : Vec2 }
vertTexturedRect =
    [glsl|

attribute vec2 a_position;
uniform mat4 transform;
uniform mat4 cameraProj;

varying vec2 vcoord;
void main () {
    vec4 pos = cameraProj*transform*vec4(a_position, 0, 1);
    gl_Position = pos;
    vcoord = a_position.xy;
}
|]


fragTextured : Shader {} { u | texture : Texture, tileWH : Vec2 } { vcoord : Vec2 }
fragTextured =
    [glsl|

precision mediump float;

uniform sampler2D texture;
uniform vec2 tileWH;
varying vec2 vcoord;

void main () {
  gl_FragColor = texture2D(texture, vcoord*tileWH);
}
|]



-- duration : Float, time : Float


fragAnimTextured : Shader {} { u | texture : Texture, bottomLeft : Vec2, topRight : Vec2, numberOfFrames : Int, duration : Float, time : Float } { vcoord : Vec2 }
fragAnimTextured =
    [glsl|

precision mediump float;

uniform sampler2D texture;
uniform vec2 bottomLeft;
uniform vec2 topRight;
uniform int numberOfFrames;
uniform float duration;
uniform float time;
varying vec2 vcoord;

void main () {
    float t = time;
    float n = float(numberOfFrames);
    float framePos = floor((mod(t, duration) / duration) * n );
    vec2 stripSize = topRight - bottomLeft;
    vec2 frameSize = vec2(stripSize.x / n, stripSize.y);
    vec2 texCord = bottomLeft + vec2(frameSize.x * framePos, 0) + vcoord * frameSize;
    //vec2 texCord = vcoord * frameSize;

    gl_FragColor = texture2D(texture, texCord);
    //gl_FragColor = vec4(framePos/5.0, 0, 0, 1);
}
|]


vertColoredRect : Shader Vertex { a | transform : Mat4, cameraProj : Mat4 } {}
vertColoredRect =
    [glsl|

// the coordiantes of our box
attribute vec2 a_position;
uniform mat4 transform;
uniform mat4 cameraProj;

void main() {

    vec4 pos = cameraProj*transform*vec4(a_position, 0, 1);
    gl_Position = pos;
}
|]


fragUniColor : Shader {} { u | color : Vec3 } {}
fragUniColor =
    [glsl|

precision mediump float;

uniform vec3 color;

void main() {
    gl_FragColor = vec4(color, 1);
}
|]
