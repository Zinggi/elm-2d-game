module Game.TwoD.Mouse exposing (elementToGameCoordinates, relativeClickPosition)

import Game.TwoD.Camera exposing (Camera, getPosition, getViewSize)
import Math.Vector2 exposing (Vec2, vec2)
import Json.Decode as Decode


{- |
   Decode a "click" event message to extract the click position relative to the target element's top left corner.

       div [Events.on "click" (relativeClickPosition ClickMessage)] []

-}


relativeClickPosition : ({ x : Int, y : Int } -> msg) -> Decode.Decoder msg
relativeClickPosition message =
    let
        relative : String -> String -> Decode.Decoder Int
        relative pageProp targetProp =
            Decode.map2 (-)
                (Decode.at [ pageProp ] Decode.int)
                (Decode.at [ "target", targetProp ] Decode.int)

        xRelative =
            relative "pageX" "offsetLeft"

        yRelative =
            relative "pageY" "offsetTop"

        positionDecoder : Decode.Decoder { x : Int, y : Int }
        positionDecoder =
            Decode.map2 (\x y -> { x = x, y = y }) xRelative yRelative
    in
        Decode.map message positionDecoder



{- |
   Convert coordinates on the canvas element to coordinates in the game.
   Coordinates on the canvas element are given relative to its top left corner.

      elementToGameCoordinates camera (elementWidth, elementHeight) (positionX, positionY)

-}


elementToGameCoordinates : Camera -> ( Int, Int ) -> ( Int, Int ) -> Vec2
elementToGameCoordinates camera ( width, height ) ( x, y ) =
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
        vec2
            (viewLeft + ((toFloat x - screenLeft) / (screenRight - screenLeft) * (viewRight - viewLeft)))
            (viewTop + ((toFloat y - screenTop) / (screenBottom - screenTop) * (viewBottom - viewTop)))
