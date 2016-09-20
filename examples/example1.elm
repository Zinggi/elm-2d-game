module Example1 exposing (..)

import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (program)
import WebGL exposing (Texture)
import Task
import Dict exposing (Dict)
import AnimationFrame


--

import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD.Render as Render
import Game.TwoD as Game
import Helpers exposing (..)


type alias Model =
    { camera : Camera {}
    , textures : Dict String Texture
    , time : Float
    }


type Msg
    = Tick Float
    | LoadTexture String Texture
    | FailedToLoadTexture String


init : ( Model, Cmd Msg )
init =
    { camera = Camera.init ( 1, 1 ) 10
    , textures = Dict.empty
    , time = 0
    }
        ! [ loadTextures FailedToLoadTexture LoadTexture [ "images/box.png", "images/guy.png" ] ]


subs m =
    AnimationFrame.diffs Tick


loadTexture url msg =
    Task.perform
        (\e -> Debug.crash ("texture loading failed: " ++ toString e))
        msg
        (WebGL.loadTexture url)


renderRect size ( x, y ) isRed =
    Render.rectangle
        { position = ( x, y )
        , size = size
        , color =
            if isRed then
                Color.red
            else
                Color.blue
        }


renderBar r =
    Render.rectangleWithOptions
        { position = ( 0, -0.01, 0 )
        , rotation = (r * pi * 2)
        , size = ( 3, 0.02 )
        , pivot = ( 0, 0 )
        , color = Color.black
        }


renderBox ( w, h ) ( x, y ) r tileY tex =
    Render.spriteWithOptions
        { size = ( w, h )
        , position = ( x, y, 0 )
        , rotation = r
        , pivot = ( 0.5, 0.5 )
        , tiling = ( 1, tileY )
        , texture = tex
        }


update msg model =
    case msg of
        LoadTexture url t ->
            { model | textures = Dict.insert url t model.textures } ! []

        FailedToLoadTexture url ->
            Debug.crash ("Failed to load texture: \"" ++ url ++ "\"")

        Tick dt ->
            { model | time = model.time + dt } ! []


view : Model -> Html Msg
view m =
    Game.renderCenteredWithOptions
        [ style [ ( "background-color", "aliceblue" ) ] ]
        [ style [ ( "border", "cadetblue" ), ( "border-style", "solid" ) ] ]
        { time = m.time, camera = m.camera, size = ( 800, 600 ) }
        [ renderRect ( 1, 1 ) ( 0, 0 ) True
        , renderRect ( 1, 2 ) ( 1, 0 ) False
        , renderBar 0
        , renderBar (1 / 4)
        , renderBox ( 1, 3 ) ( 2, 0 ) 0 3 (Dict.get "images/box.png" m.textures)
        , renderGuy (Dict.get "images/guy.png" m.textures) ( -2, 0 ) 1 1000
        , renderGuy (Dict.get "images/guy.png" m.textures) ( -3, 0 ) -1 1080
        , renderBox ( 0.5, 0.5 ) ( -1, 0 ) (0.001 * m.time) 1 (Dict.get "images/box.png" m.textures)
        ]


renderGuy tex ( x, y ) flip d =
    Render.animatedSpriteWithOptions
        { position = ( x, y, 0 )
        , size = ( flip * 1, 1.5 )
        , texture = tex
        , bottomLeft = ( 0, 0 )
        , topRight = ( 1, 1 )
        , duration = d
        , numberOfFrames = 11
        , rotation = 0
        , pivot = ( 0.5, 0 )
        }


main : Program Never
main =
    program
        { view = view
        , update = update
        , init = init
        , subscriptions = subs
        }
