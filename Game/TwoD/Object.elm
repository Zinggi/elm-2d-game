module Game.TwoD.Object exposing (..)

import Color exposing (Color)
import Math.Vector3 exposing (Vec3, vec3)


type alias Object a =
    { a
        | position : Vec3
        , rotation : Float
        , pivot : Vec3
        , scale : Vec3
        , color : Vec3
    }


makeRectangle : ( Float, Float ) -> Vec3 -> Color -> Object {}
makeRectangle ( w, h ) position color =
    { position = position
    , rotation = 0
    , pivot = vec3 (0.5) (0.5) 0
    , scale = vec3 w h 1
    , color = colorToVector color
    }


colorToVector : Color -> Vec3
colorToVector color =
    case Color.toRgb color of
        { red, green, blue } ->
            vec3 (toFloat red / 256) (toFloat green / 256) (toFloat blue / 256)


makeRotatedRectangle : ( Float, Float ) -> Vec3 -> Float -> ( Float, Float ) -> Color -> Object {}
makeRotatedRectangle ( w, h ) position r ( pivotX, pivotY ) color =
    { position = position
    , rotation = 2 * pi * r
    , pivot = vec3 pivotX pivotY 0
    , scale = vec3 w h 1
    , color = colorToVector color
    }
