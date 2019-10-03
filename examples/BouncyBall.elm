module BouncyBall exposing (Model, Msg(..), init, main, subs, tick, update, view)

--

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Color
import Game.TwoD as Game
import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD.Render as Render exposing (Renderable, circle, rectangle)
import Html exposing (..)


type alias Model =
    { position : ( Float, Float )
    , velocity : ( Float, Float )
    }


type Msg
    = Tick Float


init : () -> ( Model, Cmd Msg )
init _ =
    ( { position = ( 0, 3 )
      , velocity = ( 0, 0 )
      }
    , Cmd.none
    )


subs m =
    onAnimationFrameDelta Tick


update msg model =
    case msg of
        Tick dt ->
            ( tick (dt / 1000) model
            , Cmd.none
            )


tick dt { position, velocity } =
    let
        ( ( x, y ), ( vx, vy ) ) =
            ( position, velocity )

        vy_ =
            vy - 9.81 * dt

        ( newP, newV ) =
            if y <= 0 then
                ( ( x, 0.00001 ), ( 0, -vy_ * 0.9 ) )

            else
                ( ( x, y + vy_ * dt ), ( 0, vy_ ) )
    in
    Model newP newV


view : Model -> Html Msg
view m =
    Game.renderCentered { time = 0, camera = Camera.fixedHeight 7 ( 0, 1.5 ), size = ( 800, 600 ) }
        [ Render.shape rectangle { color = Color.green, position = ( -10, -10 ), size = ( 20, 10 ) }
        , Render.shape circle { color = Color.blue, position = m.position, size = ( 0.5, 0.5 ) }
        ]


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , update = update
        , init = init
        , subscriptions = subs
        }
