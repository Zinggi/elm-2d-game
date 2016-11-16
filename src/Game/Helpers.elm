module Game.Helpers exposing (..)

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
            ( V3.toTuple v1, V3.toTuple v2 )
    in
        vec3 (x1 * x2) (y1 * y2) (z1 * z2)


add : Float2 -> Float2 -> Float2
add ( x1, y1 ) ( x2, y2 ) =
    ( x1 + x2, y1 + y2 )


sub : Float2 -> Float2 -> Float2
sub ( x1, y1 ) ( x2, y2 ) =
    ( x1 - x2, y1 - y2 )


scale : Float -> Float2 -> Float2
scale a ( x, y ) =
    ( a * x, a * y )
