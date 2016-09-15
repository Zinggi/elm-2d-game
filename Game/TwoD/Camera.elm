module Game.TwoD.Camera exposing (..)

import Math.Vector2 exposing (..)
import Math.Matrix4 exposing (..)


type alias Camera =
    { position : Vec2, baseWidth : Float, width : Float }


init : ( Float, Float ) -> Float -> Camera
init ( x, y ) baseWidth =
    Camera (vec2 x y) baseWidth baseWidth


getProjectionMatrix : ( Float, Float ) -> Camera -> Mat4
getProjectionMatrix ( w, h ) { position, width } =
    let
        ( x, y ) =
            toTuple position

        ( w, h ) =
            ( 0.5 * width, 0.5 * width * h / w )

        ( l, r, d, u ) =
            ( x - w, x + w, y - h, y + h )
    in
        makeOrtho2D l r d u
