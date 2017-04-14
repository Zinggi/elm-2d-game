module Game.TwoD.Shaders exposing (..)

{-|


# Standard shaders for WebGL rendering.

You don't need this module,
unless you want to write your own vertex or fragment shader
and a shader from here already provides one half.

Or if you're using WebGL directly.


## Vertex shaders

@docs vertColoredShape, vertTexturedRect, vertParallaxScroll


## Fragment shaders

@docs fragTextured, fragAnimTextured, fragManualAnimTextured, fragUniColor, fragUniColorCircle, fragUniColorRing

---


### useful helper functions

@docs colorToRGBAVector, colorToRGBVector, makeTransform

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
    let
        trans =
            M4.makeTranslate (vec3 x y z)

        rot =
            M4.makeRotate rotation (vec3 0 0 1)

        scale =
            M4.makeScale (vec3 w h 1)

        pivot =
            M4.makeTranslate (vec3 -px -py 0)
    in
        (M4.mul (M4.mul (M4.mul trans rot) scale) pivot)


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


{-| A simple shader that passes the texture coordinates along for the fragment shader.
Can be generally used if the fragment shader needs to display texture(s).
-}
vertTexturedRect : Shader Vertex { u | transform : Mat4, cameraProj : Mat4 } { vcoord : Vec2 }
vertTexturedRect =
    [glsl|
attribute vec2 position;

uniform mat4 transform;
uniform mat4 cameraProj;

varying vec2 vcoord;
void main () {
    vec4 pos = cameraProj*transform*vec4(position, 0, 1);
    gl_Position = pos;
    vcoord = position.xy;
}
|]


{-| Display a tiled texture.
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
    gl_FragColor = texture2D(texture, vcoord*tileWH);
}
|]


{-| A shader to render spritesheet animations.
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

    gl_FragColor = texture2D(texture, texCoord.xy);
}
|]


{-| Same as the shader above, but controlled via frame number instead of time
-}
fragManualAnimTextured : Shader {} { u | texture : Texture, bottomLeft : Vec2, topRight : Vec2, numberOfFrames : Int, currentFrame : Int } { vcoord : Vec2 }
fragManualAnimTextured =
    [glsl|

precision mediump float;

uniform sampler2D texture;
uniform vec2 bottomLeft;
uniform vec2 topRight;
uniform int numberOfFrames;
uniform int currentFrame;
varying vec2 vcoord;

void main () {
    float n = float(numberOfFrames);
    float framePos = float(currentFrame);
    vec2 stripSize = topRight - bottomLeft;
    vec2 frameSize = vec2(stripSize.x / n, stripSize.y);
    vec2 texCoord = bottomLeft + vec2(frameSize.x * framePos, 0) + vcoord * frameSize;

    gl_FragColor = texture2D(texture, texCoord.xy);
}
|]


{-| The most basic shader, renders a basic shape.
Since it doesn't even pass along the texture coordinates,
it's only use is to create a colored shape.
-}
vertColoredShape : Shader Vertex { a | transform : Mat4, cameraProj : Mat4 } { vcoord : Vec2 }
vertColoredShape =
    [glsl|
attribute vec2 position;

uniform mat4 transform;
uniform mat4 cameraProj;
varying vec2 vcoord;
void main() {
    gl_Position = cameraProj*transform*vec4(position, 0, 1);
    vcoord = position.xy;
}
|]


{-| A very simple shader, coloring the whole area in a single color
-}
fragUniColor : Shader {} { u | color : Vec3 } { vcoord : Vec2 }
fragUniColor =
    [glsl|

precision mediump float;

uniform vec3 color;
varying vec2 vcoord;

void main() {
    gl_FragColor = vec4(color, 1);
}
|]


{-| A fragment Shader for rendering a single colored circle
-}
fragUniColorCircle : Shader {} { u | color : Vec3 } { vcoord : Vec2 }
fragUniColorCircle =
    [glsl|

precision mediump float;

uniform vec3 color;
varying vec2 vcoord;

void main () {
  float dist = length(vec2(0.5, 0.5) - vcoord);

  float alpha = smoothstep(0.5 - 0.01, 0.5, dist);
  vec4 color = vec4(color, 1.0 - alpha);

  gl_FragColor = color;
}
|]


{-| A fragment Shader for rendering a transparent circle with a colored border
-}
fragUniColorRing : Shader {} { u | color : Vec3 } { vcoord : Vec2 }
fragUniColorRing =
    [glsl|

precision mediump float;

uniform vec3 color;
varying vec2 vcoord;

void main () {
  float dist = length(vec2(0.5, 0.5) - vcoord);

  float alpha = smoothstep(0.5, 0.5 - 0.01, dist) * smoothstep(0.49 - 0.01, 0.49, dist);
  vec4 color = vec4(color, alpha);

  gl_FragColor = color;
}
|]


{-| A shader that scrolls it's texture when the camera moves, but at not at the same speed.
Good for background images.
-}
vertParallaxScroll : Shader Vertex { u | cameraPos : Vec2, cameraSize : Vec2, scrollSpeed : Vec2, z : Float, offset : Vec2 } { vcoord : Vec2 }
vertParallaxScroll =
    [glsl|
attribute vec2 position;

uniform vec2 cameraPos;
uniform vec2 cameraSize;
uniform vec2 scrollSpeed;
uniform vec2 offset;
uniform float z;

varying vec2 vcoord;

void main()
{
    vcoord =
        (position - vec2(0.5, 0.5)) // offset to middle of texture
        * normalize(cameraSize) // scale to keep aspect ratio
        - offset // apply offset
        + cameraPos * 0.05 * scrollSpeed;

    gl_Position = vec4(position*2.0 - vec2(1.0, 1.0), -z, 1);
}
|]
