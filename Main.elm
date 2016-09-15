module Main exposing (..)

import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (program)
import Math.Vector3 as V3 exposing (..)


--

import Game.TwoD.Object exposing (..)
import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD as Game


type alias Model =
    { camera : Camera
    , objects : List Object
    }


type Object
    = Rect ( Float, Float ) ( Float, Float ) Bool
    | Bar Float


init : Model
init =
    { camera = Camera.init ( 1, 1 ) 4
    , objects =
        [ Rect ( 1, 1 ) ( 0, 0 ) True
        , Rect ( 1, 2 ) ( 1, 0 ) False
        , Bar 0
        , Bar (1 / 4)
        ]
    }


render : Object -> Game.RenderObject
render object =
    case object of
        Rect size ( x, y ) isRed ->
            Game.renderRectangle size ( x, y, 0 ) <|
                if isRed then
                    Color.red
                else
                    Color.blue

        Bar r ->
            Game.ColoredRectangle
                { transform = Game.makeTransform ( 0, -0.01, 0 ) (r * pi * 2) ( 3, 0.02 ) ( 0, 0 )
                , color =
                    colorToVector Color.black
                }


update _ m =
    m ! []


view : Model -> Html Never
view m =
    Game.renderCenteredWithOptions
        [ style [ ( "background-color", "aliceblue" ) ] ]
        [ style [ ( "border", "cadetblue" ), ( "border-style", "solid" ) ] ]
        ( 800, 600 )
        m.camera
        (List.map render m.objects)



--
-- view : Model -> Html Never
-- view m =
--     Game.renderCenteredWithOptions
--         [ style [ ( "background-color", "aliceblue" ) ] ]
--         [ style [ ( "border", "cadetblue" ), ( "border-style", "solid" ) ] ]
--         ( 800, 600 )
--         m.camera
--         (List.map Game.renderObject
--             [ makeRectangle ( 1, 1 ) (vec3 0 0 0) Color.red
--             , makeRectangle ( 1, 2 ) (vec3 1 0 0) Color.blue
--             , makeRotatedRectangle ( 3, 0.02 ) (vec3 0 -0.01 0) (1 / 4) ( 0, 0.5 ) Color.black
--             , makeRotatedRectangle ( 3, 0.02 ) (vec3 0 -0.01 0) (0) ( 0, 0.5 ) Color.black
--             ]
--         )


main : Program Never
main =
    program
        { view = view
        , update = update
        , init = init ! []
        , subscriptions = (\_ -> Sub.none)
        }
