module Tests exposing (..)

import Game.TwoD.Mouse exposing (elementToGameCoordinates, relativeClickPosition)
import Game.TwoD.Camera exposing (Camera, custom, moveBy)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Json.Decode exposing (decodeString)
import Math.Vector2 exposing (toTuple)


pixelRange =
    Fuzz.intRange 0 100


toElementToGameCoordinatesTest : Camera -> ( Int, Int ) -> ( Int, Int ) -> ( Float, Float ) -> Test
toElementToGameCoordinatesTest camera view click expected =
    let
        result =
            elementToGameCoordinates camera view click
    in
        test ("clicking on " ++ toString click ++ " with camera " ++ toString camera) <|
            \() -> Expect.equal (toTuple result) expected


mouse : Test
mouse =
    describe "Mouse Module"
        [ describe "relative click decoding"
            [ fuzz4 pixelRange pixelRange pixelRange pixelRange "decoder extracts offset data from click event message" <|
                \x y left top ->
                    let
                        event =
                            toEvent x y left top

                        decoded =
                            decodeString (relativeClickPosition (\a -> a)) event

                        toEvent =
                            \x y left top ->
                                "{"
                                    ++ "\"pageX\": "
                                    ++ toString x
                                    ++ ","
                                    ++ "\"pageY\": "
                                    ++ toString y
                                    ++ ","
                                    ++ "\"target\": {"
                                    ++ "\"offsetLeft\": "
                                    ++ toString left
                                    ++ ","
                                    ++ "\"offsetTop\": "
                                    ++ toString top
                                    ++ "}"
                                    ++ "}"
                    in
                        case decoded of
                            Ok pos ->
                                Expect.equal { x = x - left, y = y - top } pos

                            Err e ->
                                Expect.fail ("Failed to decode with error: " ++ e)
            ]
        , describe "mapping click to game position" <|
            List.map
                (\( camera, view, click, expected ) -> toElementToGameCoordinatesTest camera view click expected)
                [ ( custom (\_ -> ( 2, 2 )) ( 0, 0 ), ( 100, 100 ), ( 0, 0 ), ( -1, 1 ) )
                , ( custom (\_ -> ( 2, 2 )) ( 0, 0 ), ( 100, 100 ), ( 0, 100 ), ( -1, -1 ) )
                , ( custom (\_ -> ( 2, 2 )) ( 0, 0 ), ( 100, 100 ), ( 100, 0 ), ( 1, 1 ) )
                , ( custom (\_ -> ( 2, 2 )) ( 0, 0 ), ( 100, 100 ), ( 100, 100 ), ( 1, -1 ) )
                , ( moveBy ( 1, 0 ) <| custom (\_ -> ( 2, 2 )) ( 0, 0 ), ( 100, 100 ), ( 0, 0 ), ( 0, 1 ) )
                , ( moveBy ( 0, 1 ) <| custom (\_ -> ( 2, 2 )) ( 0, 0 ), ( 100, 100 ), ( 0, 0 ), ( -1, 2 ) )
                ]
        ]
