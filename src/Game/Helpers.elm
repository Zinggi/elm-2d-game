module Game.Helpers exposing (..)

import Color exposing (Color)
import Math.Matrix4 as M4 exposing (Mat4)
import Math.Vector3 as V3 exposing (Vec3, vec3)


type alias Float2 =
    ( Float, Float )


type alias Int2 =
    ( Int, Int )


type alias Float3 =
    ( Float, Float, Float )


makeTransform : ( Float, Float, Float ) -> Float -> ( Float, Float ) -> ( Float, Float ) -> Mat4
makeTransform ( x, y, z ) rotation ( w, h ) ( px, py ) =
    (M4.makeTranslate ((vec3 x y z) `V3.add` (vec3 (abs w * px) (abs h * py) 0)))
        `M4.mul` (M4.makeRotate rotation (vec3 0 0 1))
        `M4.mul` (M4.makeScale (vec3 w h 1))
        `M4.mul` (M4.makeTranslate (vec3 -px -py 0))


mul3 : Vec3 -> Vec3 -> Vec3
mul3 v1 v2 =
    let
        ( ( x1, y1, z1 ), ( x2, y2, z2 ) ) =
            ( V3.toTuple v1, V3.toTuple v2 )
    in
        vec3 (x1 * x2) (y1 * y2) (z1 * z2)


colorToVector : Color -> Vec3
colorToVector color =
    case Color.toRgb color of
        { red, green, blue } ->
            vec3 (toFloat red / 256) (toFloat green / 256) (toFloat blue / 256)
