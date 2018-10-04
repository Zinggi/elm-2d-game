module Game.Helpers exposing (Float2, Float3, Int2, add, mul3, scale, sub, v2FromTuple)

import Math.Vector2 as V2 exposing (Vec2, vec2)
import Math.Vector3 as V3 exposing (Vec3, vec3)


type alias Float2 =
    ( Float, Float )


type alias Int2 =
    ( Int, Int )


type alias Float3 =
    ( Float, Float, Float )


mul3 : Vec3 -> Vec3 -> Vec3
mul3 v1 v2 =
    let
        ( ( x1, y1, z1 ), ( x2, y2, z2 ) ) =
            ( v3ToTuple v1, v3ToTuple v2 )
    in
    vec3 (x1 * x2) (y1 * y2) (z1 * z2)


v2FromTuple : Float2 -> Vec2
v2FromTuple ( x, y ) =
    vec2 x y


v3ToTuple : Vec3 -> Float3
v3ToTuple v3 =
    let
        { x, y, z } =
            V3.toRecord v3
    in
    ( x, y, z )


add : Float2 -> Float2 -> Float2
add ( x1, y1 ) ( x2, y2 ) =
    ( x1 + x2, y1 + y2 )


sub : Float2 -> Float2 -> Float2
sub ( x1, y1 ) ( x2, y2 ) =
    ( x1 - x2, y1 - y2 )


scale : Float -> Float2 -> Float2
scale a ( x, y ) =
    ( a * x, a * y )
