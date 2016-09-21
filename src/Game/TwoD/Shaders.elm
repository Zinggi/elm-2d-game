module Game.TwoD.Shaders exposing (..)

{-|
# Standard shaders for WebGL rendering.

You don't need this module,
unless you want to write your own vertex or fragment shader
and a shader from here already provides one half.

Or if you're using WebGL directly.

## Vertex shaders
@docs vertColoredRect
@docs vertTexturedRect

## Fragment shaders
@docs fragTextured
@docs fragAnimTextured
@docs fragUniColor
-}

import WebGL exposing (Shader, Texture)
import Game.TwoD.Shapes exposing (Vertex)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)


{-|
A simple shader that passes the texture coordinates along for the fragment shader.
Can be generally used if the fragment shader needs to display texture(s).
-}
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


{-|
Display a tiled texture.
TileWH specifies how many times the texture should be tiled.
-}
fragTextured : Shader {} { u | texture : Texture, tileWH : Vec2 } { vcoord : Vec2 }
fragTextured =
    [glsl|

precision mediump float;

uniform sampler2D texture;
uniform vec2 tileWH;
varying vec2 vcoord;

void main () {
    vec4 temp = texture2D(texture, vcoord*tileWH);
    gl_FragColor = vec4(temp.xyz*temp.a, temp.a);
}
|]


{-|
A shader to render spritesheet animations.
It assumes that the animation frames are in one horizontal line
-}
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
    float n = float(numberOfFrames);
    float framePos = floor((mod(time, duration) / duration) * n );
    vec2 stripSize = topRight - bottomLeft;
    vec2 frameSize = vec2(stripSize.x / n, stripSize.y);
    vec2 texCoord = bottomLeft + vec2(frameSize.x * framePos, 0) + vcoord * frameSize;

    vec4 temp = texture2D(texture, texCoord.xy);
    gl_FragColor = vec4(temp.xyz*temp.a, temp.a);
}
|]


{-|
The most basic shader, renders a rectangle.
Since it doesn't even pass along the texture coordinates,
it's only use is to create a colored rectangle.
-}
vertColoredRect : Shader Vertex { a | transform : Mat4, cameraProj : Mat4 } {}
vertColoredRect =
    [glsl|

// the coordiantes of our box
attribute vec2 a_position;
uniform mat4 transform;
uniform mat4 cameraProj;

void main() {
    gl_Position = cameraProj*transform*vec4(a_position, 0, 1);
}
|]


{-|
A very simple shader, coloring the whole area in a single color
-}
fragUniColor : Shader {} { u | color : Vec3 } {}
fragUniColor =
    [glsl|

precision mediump float;

uniform vec3 color;

void main() {
    gl_FragColor = vec4(color, 1);
}
|]
