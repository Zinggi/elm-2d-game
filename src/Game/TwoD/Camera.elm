module Game.TwoD.Camera exposing (Camera, init, getProjectionMatrix, getPosition, withZoom, setZoom, getZoom, follow, moveBy, moveTo)

{-|
This provides a basic camera.

You don't have to use this functions to get a working camera,
you can just follow the `Camera` type.

E.g. in my game I have a camera that can follow the player and that does the right thing when the player dies etc.

@docs Camera

@docs init

@docs getPosition

@docs moveBy

@docs moveTo

@docs follow


@docs withZoom

@docs setZoom

@docs getZoom
---
## used internally

@docs getProjectionMatrix
-}

import Math.Vector2 as V2 exposing (..)
import Math.Matrix4 exposing (..)


{-|
A camera that always shows `width` units of the world.
It's an extensible record so that you can write your own camera
-}
type alias Camera a =
    { a | position : Vec2, width : Float }


{-|
Create a simple camera.
-}
init : ( Float, Float ) -> Float -> Camera {}
init ( x, y ) width =
    { position = vec2 x y, width = width }


{-|
Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.
-}
getProjectionMatrix : ( Float, Float ) -> Camera a -> Mat4
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


{-|
-}
getPosition : Camera a -> ( Float, Float )
getPosition camera =
    toTuple camera.position


{-|
Create a camera with zooming capabilities. Serves as an example on how to create your own camera type
-}
withZoom : ( Float, Float ) -> Float -> Camera { baseWidth : Float }
withZoom ( x, y ) baseWidth =
    { position = vec2 x y, baseWidth = baseWidth, width = baseWidth }


{-|
Move a camera by the given vector *relative* to the camera.
-}
moveBy : ( Float, Float ) -> Camera a -> Camera a
moveBy ( x, y ) camera =
    { camera | position = add camera.position (vec2 x y) }


{-|
Move a camera to the given location. In *absolute* coordinates.
-}
moveTo : ( Float, Float ) -> Camera a -> Camera a
moveTo ( x, y ) camera =
    { camera | position = vec2 x y }


{-|
Smoothly follow the given target. Use this in your tick function.

    follow 1.5 dt target camera

-}
follow : Float -> Float -> ( Float, Float ) -> Camera a -> Camera a
follow speed dt ( x, y ) ({ position } as camera) =
    let
        target =
            vec2 x y

        vectorToTarget =
            (target `sub` position)

        newPosition =
            (position `add` (V2.scale (speed * dt) vectorToTarget))
    in
        { camera | position = newPosition }


{-|
-}
setZoom : Float -> Camera { baseWidth : Float } -> Camera { baseWidth : Float }
setZoom z c =
    { c | width = c.baseWidth * z }


{-|
-}
getZoom : Camera { baseWidth : Float } -> Float
getZoom { baseWidth, width } =
    width / baseWidth
