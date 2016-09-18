module Example2 exposing (..)

import Color
import Html exposing (..)
import Html.App exposing (program)
import AnimationFrame


--

import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD.Render as Render
import Game.TwoD as Game


type alias Model =
    { camera : Camera {}
    , time : Float
    , m : ( ( Float, Float ), ( Float, Float ) )
    }


type Msg
    = Tick Float


init : ( Model, Cmd Msg )
init =
    { camera = Camera.init ( 0, 0 ) 15
    , time = 0
    , m = ( ( 0, 3 ), ( 0, 0 ) )
    }
        ! []


subs m =
    AnimationFrame.diffs Tick


update msg model =
    case msg of
        Tick dt ->
            tick (dt / 1000) { model | time = model.time + dt } ! []


tick dt ({ m } as model) =
    let
        ( ( x, y ), ( vx, vy ) ) =
            m

        vy' =
            vy - 9.81 * dt

        newPos =
            if y <= 0 then
                ( ( x, y - vy' * dt ), ( 0, -vy' * 0.9 ) )
            else
                ( ( x, y + vy' * dt ), ( 0, vy' ) )
    in
        { model | m = newPos }


view : Model -> Html Msg
view m =
    Game.renderCentered m.time
        ( 800, 600 )
        m.camera
        [ Render.rectangle { color = Color.blue, position = fst m.m, size = ( 0.2, 0.2 ) }
        ]


main : Program Never
main =
    program
        { view = view
        , update = update
        , init = init
        , subscriptions = subs
        }
