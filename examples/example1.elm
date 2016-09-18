module Example1 exposing (..)

import Color
import Game.TwoD.App as Game
import Html
import Game.TwoD.Camera as Camera
import Game.TwoD.Render as Render


init =
    ( ( 0, 3 ), ( 0, 0 ) )


tick dt input ( ( x, y ), ( vx, vy ) ) =
    let
        dt' =
            (dt / 1000)

        vy' =
            vy + g * dt'
    in
        if y <= 0 then
            ( ( x, y - vy' * dt' ), ( 0, -vy' * 0.9 ) )
        else
            ( ( x, y + vy' * dt' ), ( 0, vy' ) )


g =
    -9.81


render ( ( x, y ), ( vx, vy ) ) =
    ( Camera.init ( 0, 0 ) 15
    , [ Render.rectangle { color = Color.blue, position = ( x, y ), size = ( 0.2, 0.2 ) }
      ]
    )


main =
    Game.start
        { init = init
        , tick = tick
        , render = render
        }
