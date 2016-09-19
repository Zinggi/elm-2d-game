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
    { position : ( Float, Float )
    , velocity : ( Float, Float )
    }


type Msg
    = Tick Float


init : ( Model, Cmd Msg )
init =
    { position = ( 0, 3 )
    , velocity = ( 0, 0 )
    }
        ! []


subs m =
    AnimationFrame.diffs Tick


update msg model =
    case msg of
        Tick dt ->
            tick (dt / 1000) model ! []


tick dt { position, velocity } =
    let
        ( ( x, y ), ( vx, vy ) ) =
            ( position, velocity )

        vy' =
            vy - 9.81 * dt

        ( newP, newV ) =
            if y <= 0 then
                ( ( x, 0.00001 ), ( 0, -vy' * 0.9 ) )
            else
                ( ( x, y + vy' * dt ), ( 0, vy' ) )
    in
        Model newP newV


view : Model -> Html Msg
view m =
    Game.renderCentered { time = 0, camera = Camera.init ( 0, 1.5 ) 5, size = ( 800, 600 ) }
        [ Render.rectangle { color = Color.blue, position = m.position, size = ( 0.2, 0.2 ) }
        , Render.rectangle { color = Color.green, position = ( -10, -10 ), size = ( 20, 10 ) }
        ]


main : Program Never
main =
    program
        { view = view
        , update = update
        , init = init
        , subscriptions = subs
        }
