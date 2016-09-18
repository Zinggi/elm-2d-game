module Game.TwoD.Camera exposing (Camera, init, getProjectionMatrix)

{-|
This provides a basic camera.

@docs Camera

@docs init

---
used internally
@docs getProjectionMatrix
-}

import Math.Vector2 exposing (..)
import Math.Matrix4 exposing (..)


{-|
A camera that always shows `width` units of the world.
It's an extensible record so that you could write your own camera
-}
type alias Camera a =
    { a | position : Vec2, width : Float }


{-|
Create a camera. You can also just use a record literal instead
-}
init : ( Float, Float ) -> Float -> Camera {}
init ( x, y ) width =
    { position = vec2 x y, width = width }


{-|
Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader
-}
getProjectionMatrix : ( Float, Float ) -> { a | position : Vec2, width : Float } -> Mat4
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
