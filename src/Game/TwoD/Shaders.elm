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
@docs vertParallaxScroll

## Fragment shaders
@docs fragTextured
@docs fragAnimTextured
@docs fragUniColor
-}

import WebGL exposing (Shader, Texture)
import Color exposing (Color)
import Game.TwoD.Shapes exposing (Vertex)
import Math.Matrix4 as M4 exposing (Mat4)
import Math.Vector2 as V2 exposing (Vec2)
import Math.Vector3 as V3 exposing (Vec3, vec3)
import Math.Vector4 exposing (Vec4, vec4)
import Game.Helpers exposing (..)


{-| Creates a transformation matrix usually used in the fragment shader.

    makeTransform ( x, y, z ) rotation ( w, h ) ( px, py )
-}
makeTransform : Float3 -> Float -> Float2 -> Float2 -> Mat4
makeTransform ( x, y, z ) rotation ( w, h ) ( px, py ) =
    (M4.makeTranslate ((vec3 x y z) `V3.add` (vec3 (abs w * px) (abs h * py) 0)))
        `M4.mul` (M4.makeRotate rotation (vec3 0 0 1))
        `M4.mul` (M4.makeScale (vec3 w h 1))
        `M4.mul` (M4.makeTranslate (vec3 -px -py 0))


{-| -}
colorToRGBVector : Color -> Vec3
colorToRGBVector color =
    case Color.toRgb color of
        { red, green, blue } ->
            vec3 (toFloat red / 256) (toFloat green / 256) (toFloat blue / 256)


{-| -}
colorToRGBAVector : Color -> Vec4
colorToRGBAVector color =
    case Color.toRgb color of
        { red, green, blue, alpha } ->
            vec4 (toFloat red / 256) (toFloat green / 256) (toFloat blue / 256) (alpha / 256)


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


{-|
A shader that scrolls it's texture when the camera moves, but at not at the same speed.
Good for background images.
-}
vertParallaxScroll : Shader Vertex { u | cameraProj : Mat4, scrollSpeed : Vec3, z : Float, offset : Vec2 } { vcoord : Vec2 }
vertParallaxScroll =
    [glsl|
attribute vec2 a_position;
uniform mat4 cameraProj;
uniform vec3 scrollSpeed;
uniform vec2 offset;
uniform float z;
varying vec2 vcoord;

void main()
{
    vec2 xy_size = 0.25/vec2(cameraProj[0][0], cameraProj[1][1]);
    vec2 cameraPos = vec2(cameraProj[3][0], cameraProj[3][1]);

    vcoord =
        (a_position - vec2(0.5, 0.5)) // offset to middle of texture
        * vec2(1.0, xy_size.y/xy_size.x) * ((1.0 - scrollSpeed.z) + xy_size.x * scrollSpeed.z) // scale to keep aspect ratio
        - offset // apply offset
        - cameraPos * xy_size * scrollSpeed.xy; // only move with some percentage of camera position

    gl_Position = vec4(a_position*2.0 - vec2(1.0, 1.0), -z, 1);
}
|]
