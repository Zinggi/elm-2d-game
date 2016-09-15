module Main exposing (..)

import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (program)
import Math.Vector2 as V2 exposing (..)
import Math.Vector3 as V3 exposing (..)


--

import Game.TwoD.Object exposing (..)
import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD as Game


type alias Model =
    { camera : Camera
    }


init : Model
init =
    { camera = Camera.init (vec2 1 1) 4
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
        [ makeRectangle ( 1, 1 ) (vec3 0 0 0) Color.red
        , makeRectangle ( 1, 2 ) (vec3 1 0 0) Color.blue
        , makeRotatedRectangle ( 3, 0.02 ) (vec3 0 -0.01 0) (1 / 4) ( 0, 0.5 ) Color.black
        , makeRotatedRectangle ( 3, 0.02 ) (vec3 0 -0.01 0) (0) ( 0, 0.5 ) Color.black
        ]


main : Program Never
main =
    program
        { view = view
        , update = update
        , init = init ! []
        , subscriptions = (\_ -> Sub.none)
        }
