module Game.TwoD.Camera exposing (Camera, fixedWidth, fixedHeight, fixedArea, custom, view, getViewSize, getPosition, follow, moveBy, moveTo, viewportToGameCoordinates)

{-| A camera to view the game world.


## camera creation

@docs Camera, fixedArea, fixedWidth, fixedHeight, custom


## manipulate camera

@docs getPosition, moveBy, moveTo, follow

---


## camera transformations

@docs view, getViewSize, viewportToGameCoordinates

-}

import Math.Matrix4 as M4 exposing (Mat4)
import Game.Helpers exposing (..)


type Size
    = Width Float
    | Height Float
    | Area Float
    | Custom (( Float, Float ) -> ( Float, Float ))


{-| A camera represents how to render the virtual world.
It's essentially a transformation from virtual game coordinates to pixel coordinates on the screen.
-}
type Camera
    = Camera { size : Size, position : ( Float, Float ) }


{-| A camera that always shows `width` units of your game horizontally.
Well suited for a side-scroller.
-}
fixedWidth : Float -> ( Float, Float ) -> Camera
fixedWidth w pos =
    Camera { size = Width w, position = pos }


{-| A camera that always shows `height` units of your game vertically.
Well suited for a vertical scroller.
-}
fixedHeight : Float -> ( Float, Float ) -> Camera
fixedHeight h pos =
    Camera { size = Height h, position = pos }


{-| A camera that always shows the same area.
This is useful in a top down game.
You probably want to specify the area as a multiplication of width and height:

    fixedArea (16*10) (x, y)

This means the camera will always show 160 square units of your game.
In practice, this means that on a 16:10 viewport, 16 by 10 units of your game will be visible.
But on a 4:3 viewport it would show 14.6 by 10.95 units. (sqrt(16*10*4/3)=14.6, sqrt(16*10*3/4)=10.95)

-}
fixedArea : Float -> ( Float, Float ) -> Camera
fixedArea a pos =
    Camera { size = Area a, position = pos }


{-| The custom camera allows you to use a function
that maps viewport size (in pixel) to game units.
E.g. here's an implementation of the fixedWidth camera using custom:

    fixedWidth width =
        custom (\( w, h ) -> ( width, width * h / w ))

-}
custom : (( Float, Float ) -> ( Float, Float )) -> ( Float, Float ) -> Camera
custom fn pos =
    Camera { size = Custom fn, position = pos }


{-| Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.
-}
view : Camera -> ( Float, Float ) -> Mat4
view ((Camera { position }) as camera) size =
    let
        ( x, y ) =
            position

        ( w, h ) =
            scale 0.5 (getViewSize size camera)

        ( l, r, d, u ) =
            ( x - w, x + w, y - h, y + h )
    in
        M4.makeOrtho2D l r d u


{-| Given the screen size, gets the width and height in game units
-}
getViewSize : ( Float, Float ) -> Camera -> ( Float, Float )
getViewSize ( w, h ) (Camera { size }) =
    case size of
        Width x ->
            ( x, x * h / w )

        Height y ->
            ( y * w / h, y )

        Area a ->
            ( sqrt (a * w / h), sqrt (a * h / w) )

        Custom fn ->
            fn ( w, h )


{-| -}
getPosition : Camera -> ( Float, Float )
getPosition (Camera { position }) =
    position


{-| Move a camera by the given vector *relative* to the camera.
-}
moveBy : ( Float, Float ) -> Camera -> Camera
moveBy offset (Camera camera) =
    Camera { camera | position = add camera.position offset }


{-| Move a camera to the given location. In *absolute* coordinates.
-}
moveTo : ( Float, Float ) -> Camera -> Camera
moveTo pos (Camera camera) =
    Camera { camera | position = pos }


{-| Smoothly follow the given target. Use this in your tick function.

    follow 1.5 dt target camera

-}
follow : Float -> Float -> ( Float, Float ) -> Camera -> Camera
follow speed dt target (Camera ({ position } as camera)) =
    let
        vectorToTarget =
            (sub target position)

        newPosition =
            (add position (scale (speed * dt) vectorToTarget))
    in
        Camera { camera | position = newPosition }


{-| Convert coordinates on the canvas element to coordinates in the game.
Coordinates on the canvas element are given relative to its top left corner.

    viewportToGameCoordinates camera (elementWidth, elementHeight) (positionX, positionY)

Element click coordinates can be extracted with a package like [Elm-Canvas/ElementRelativeMouseEvents](http://package.elm-lang.org/packages/Elm-Canvas/element-relative-mouse-events/1.0.0/ElementRelativeMouseEvents)

-}
viewportToGameCoordinates : Camera -> ( Int, Int ) -> ( Int, Int ) -> ( Float, Float )
viewportToGameCoordinates camera ( width, height ) ( x, y ) =
    let
        {- Screen is (Ws, Hs) and starts at (0,0) to (Ws, Hs)
           view size is (Wv, Hv) starting from (-Wv / 2, -Hv / 2) to (Wv / 2, Hv / 2)
           so screen position (Ws, Hs) should be (Wv / 2, Hv / 2)
           so Ws = Wv / 2 -> Wv = 2 Ws
        -}
        ( screenLeft, screenRight, screenTop, screenBottom ) =
            ( toFloat 0, toFloat width, toFloat 0, toFloat height )

        ( gameWidth, gameHeight ) =
            getViewSize ( toFloat width, toFloat height ) camera

        ( cameraXOffset, cameraYOffset ) =
            getPosition camera

        ( viewLeft, viewRight, viewTop, viewBottom ) =
            ( (-(gameWidth / 2)) + cameraXOffset
            , (gameWidth / 2) + cameraXOffset
            , (gameHeight / 2) + cameraYOffset
            , (-(gameHeight / 2) + cameraYOffset)
            )
    in
        ( viewLeft + ((toFloat x - screenLeft) / (screenRight - screenLeft) * (viewRight - viewLeft))
        , viewTop + ((toFloat y - screenTop) / (screenBottom - screenTop) * (viewBottom - viewTop))
        )
