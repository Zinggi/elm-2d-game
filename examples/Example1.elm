module Example1 exposing (Model, Msg(..), camera, init, main, renderBar, renderBox, renderGuy, renderRect, subs, update, view)

--

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Color
import Game.Resources as Resources exposing (Resources)
import Game.TwoD as Game
import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD.Render as Render exposing (Renderable, rectangle, ring)
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { time : Float
    , resources : Resources
    }


camera : Camera
camera =
    Camera.fixedWidth 10 ( 1, 1 )


type Msg
    = Tick Float
    | Resources Resources.Msg


init : () -> ( Model, Cmd Msg )
init _ =
    ( { resources = Resources.init
      , time = 0
      }
    , Cmd.map Resources (Resources.loadTextures [ "images/box.png", "images/guy.png" ])
    )


subs m =
    onAnimationFrameDelta Tick


renderRect shape size ( x, y ) isRed =
    Render.shape shape
        { position = ( x, y )
        , size = size
        , color =
            if isRed then
                Color.red

            else
                Color.blue
        }


renderBar r =
    Render.shapeWithOptions rectangle
        { position = ( 0, -0.01, 0 )
        , rotation = r * pi * 2
        , size = ( 3, 0.02 )
        , pivot = ( 0, 0 )
        , color = Color.black
        }


renderBox res ( w, h ) ( x, y ) r tileY =
    Render.spriteWithOptions
        { size = ( w, h )
        , position = ( x, y, 0 )
        , rotation = r
        , pivot = ( 0.5, 0.5 )
        , tiling = ( 1, tileY )
        , texture = Resources.getTexture "images/box.png" res
        }


update msg model =
    case msg of
        Resources rMsg ->
            ( { model | resources = Resources.update rMsg model.resources }
            , Cmd.none
            )

        Tick dt ->
            ( { model | time = model.time + dt }
            , Cmd.none
            )


view : Model -> Html Msg
view m =
    Game.renderCenteredWithOptions
        [ style "background-color" "aliceblue" ]
        [ style "border" "cadetblue", style "border-style" "solid" ]
        { time = m.time, camera = camera, size = ( 800, 600 ) }
        [ renderRect ring ( 1, 1 ) ( 0, 0 ) True
        , renderRect rectangle ( 1, 2 ) ( 1, 0 ) False
        , renderBar 0
        , renderBar (1 / 4)
        , renderBox m.resources ( 1, 3 ) ( 2.5, 1.5 ) 0 3
        , renderGuy m.resources ( -1.5, 0 ) 1 1000
        , renderGuy m.resources ( -2.5, 0 ) -1 1080
        , renderBox m.resources ( 0.5, 0.5 ) ( -0.75, 0.25 ) (0.001 * m.time) 1
        ]


renderGuy res ( x, y ) flip d =
    Render.animatedSpriteWithOptions
        { position = ( x, y, 0 )
        , size = ( flip * 1, 1.5 )
        , texture = Resources.getTexture "images/guy.png" res
        , bottomLeft = ( 0, 0 )
        , topRight = ( 1, 1 )
        , duration = d
        , numberOfFrames = 11
        , rotation = 0
        , pivot = ( 0.5, 0 )
        }


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , update = update
        , init = init
        , subscriptions = subs
        }
