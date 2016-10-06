module Game.TwoD.Camera exposing (Camera, fixedWidth, fixedHeight, view, getPosition, follow, moveBy, moveTo)

{-|
This provides a basic camera.

You can also create your own camera type if you wish.
To do so, have a look at the source of this file.

@docs Camera, fixedWidth, fixedHeight

@docs getPosition, moveBy, moveTo, follow

@docs view
-}

import Math.Vector2 as V2 exposing (Vec2)
import Math.Matrix4 as M4 exposing (Mat4)
import Game.Helpers exposing (..)


type Kind
    = Width
    | Height


{-|
A camera represents how to render the virtual world.
It's essentially a transformation from virtual game coordinates to pixel coordinates on the screen.
-}
type alias Camera =
    { kind : Kind, size : Float, position : ( Float, Float ) }


{-|
A camera that always shows `width` units of your game horizontally.
Well suited for a side-scroller.
-}
fixedWidth : Float -> ( Float, Float ) -> Camera
fixedWidth =
    Camera Width


{-|
A camera that always shows `height` units of your game vertically.
Well suited for a vertical scroller.
-}
fixedHeight : Float -> ( Float, Float ) -> Camera
fixedHeight =
    Camera Height


{-|
Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.
-}
view : Camera -> ( Float, Float ) -> Mat4
view { position, size, kind } ( w, h ) =
    let
        ( x, y ) =
            position

        ( w, h ) =
            case kind of
                Width ->
                    ( 0.5 * size, 0.5 * size * h / w )

                Height ->
                    ( 0.5 * size * w / h, 0.5 * size )

        ( l, r, d, u ) =
            ( x - w, x + w, y - h, y + h )
    in
        M4.makeOrtho2D l r d u


{-|
-}
getPosition : Camera -> ( Float, Float )
getPosition camera =
    camera.position


{-|
Move a camera by the given vector *relative* to the camera.
-}
moveBy : ( Float, Float ) -> Camera -> Camera
moveBy offset camera =
    { camera | position = add camera.position offset }


{-|
Move a camera to the given location. In *absolute* coordinates.
-}
moveTo : ( Float, Float ) -> Camera -> Camera
moveTo pos camera =
    { camera | position = pos }


{-|
Smoothly follow the given target. Use this in your tick function.

    follow 1.5 dt target camera

-}
follow : Float -> Float -> ( Float, Float ) -> Camera -> Camera
follow speed dt target ({ position } as camera) =
    let
        vectorToTarget =
            (target `sub` position)

        newPosition =
            (position `add` (scale (speed * dt) vectorToTarget))
    in
        { camera | position = newPosition }
