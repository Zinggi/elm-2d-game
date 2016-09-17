module Main exposing (..)

import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (program)
import Math.Vector2 as V2 exposing (vec2)
import WebGL exposing (Texture)
import Task
import Time
import Dict exposing (Dict)


--

import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD.Render as Render
import Game.TwoD as Game


type alias Model =
    { camera : Camera
    , textures : Dict String Texture
    , dt : Float
    }


type Msg
    = Tick Float
    | LoadTexture String Texture
    | FailedToLoadTexture String


loadTextures : List String -> Cmd Msg
loadTextures urls =
    urls
        |> List.map
            (\url ->
                Task.perform (\_ -> FailedToLoadTexture url)
                    (LoadTexture url)
                    (WebGL.loadTexture url)
            )
        |> Cmd.batch


init : ( Model, Cmd Msg )
init =
    { camera = Camera.init ( 1, 1 ) 10
    , textures = Dict.empty
    , dt = 0
    }
        ! [ loadTextures [ "images/crate.png", "images/guy.png" ] ]


subs m =
    Time.every (Time.second / 30) Tick


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
    Render.texturedRectangleWithOptions
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
            { model | textures = Dict.insert (Debug.log "success: " url) t model.textures } ! []

        FailedToLoadTexture url ->
            Debug.crash ("Failed to load texture: \"" ++ url ++ "\"")

        Tick t ->
            { model | dt = t } ! []


view : Model -> Html Msg
view m =
    Game.renderCenteredWithOptions
        [ style [ ( "background-color", "aliceblue" ) ] ]
        [ style [ ( "border", "cadetblue" ), ( "border-style", "solid" ) ] ]
        ( 800, 600 )
        m.camera
        [ renderRect ( 1, 1 ) ( 0, 0 ) True
        , renderRect ( 1, 2 ) ( 1, 0 ) False
        , renderBar 0
        , renderBar (1 / 4)
        , renderBox ( 1, 3 ) ( 2, 0 ) 0 3 (Dict.get "images/crate.png" m.textures)
        , renderBox ( 0.5, 0.5 ) ( -1, 0 ) (0.001 * m.dt) 1 (Dict.get "images/crate.png" m.textures)
        , renderGuy (Dict.get "images/guy.png" m.textures) m.dt ( -2, 0 ) 2 1000
        , renderGuy (Dict.get "images/guy.png" m.textures) m.dt ( -3, 0 ) 1 1080
        ]


renderGuy mtex t ( x, y ) i d =
    case mtex of
        Nothing ->
            renderRect ( 1, 2 ) ( 1, 0 ) False

        Just tex ->
            Render.AnimatedSprite
                { transform = Game.makeTransform ( x, y, 0 ) (0) ( 1, 3 ) ( 0.5, 0.5 )
                , texture = tex
                , bottomLeft = vec2 0 ((1 / 4) * i - 0.0222)
                , topRight = vec2 0.99 ((1 / 4) * (i + 1))
                , duration = d
                , numberOfFrames = 6
                , time = t
                }


main : Program Never
main =
    program
        { view = view
        , update = update
        , init = init
        , subscriptions = subs
        }
