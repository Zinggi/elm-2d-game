module Tests exposing (..)

import Game.TwoD.Camera exposing (Camera, custom, moveBy, toCameraCoordinates)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Json.Decode exposing (decodeString)
import Math.Vector2 exposing (toTuple)


pixelRange =
    Fuzz.intRange 0 100


toElementToGameCoordinatesTest : { camera : Camera, click : ( Int, Int ), expected : ( Float, Float ) } -> Test
toElementToGameCoordinatesTest { camera, click, expected } =
    let
        result =
            toCameraCoordinates camera ( 100, 100 ) click
    in
        test ("clicking on " ++ toString click ++ " with camera " ++ toString camera) <|
            \() -> Expect.equal (toTuple result) expected


mapGameCoordinates : Test
mapGameCoordinates =
    describe "Mouse Module"
        [ describe "mapping click to game position" <|
            List.map
                toElementToGameCoordinatesTest
                [ { camera = custom (\_ -> ( 2, 2 )) ( 0, 0 ), click = ( 0, 0 ), expected = ( -1, 1 ) }
                , { camera = custom (\_ -> ( 2, 2 )) ( 0, 0 ), click = ( 0, 100 ), expected = ( -1, -1 ) }
                , { camera = custom (\_ -> ( 2, 2 )) ( 0, 0 ), click = ( 100, 0 ), expected = ( 1, 1 ) }
                , { camera = custom (\_ -> ( 2, 2 )) ( 0, 0 ), click = ( 100, 100 ), expected = ( 1, -1 ) }
                , { camera = moveBy ( 1, 0 ) <| custom (\_ -> ( 2, 2 )) ( 0, 0 )
                  , click = ( 0, 0 )
                  , expected = ( 0, 1 )
                  }
                , { camera = moveBy ( 0, 1 ) <| custom (\_ -> ( 2, 2 )) ( 0, 0 )
                  , click = ( 0, 0 )
                  , expected = ( -1, 2 )
                  }
                ]
        ]
