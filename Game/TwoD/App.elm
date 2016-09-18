module Game.TwoD.App exposing (startWithFlags, start)

import Html exposing (Html)
import Html.App exposing (programWithFlags)
import Dict
import AnimationFrame
import WebGL


--

import Game.TwoD.Camera exposing (Camera)
import Game.TwoD.Render exposing (Renderable)
import Game.TwoD as Game


type alias Texture =
    WebGL.Texture


type Msg msg
    = Tick Float
    | TextureLoaded String Texture
    | TextureLoadFailed String
    | User msg


type OutMsg
    = TextureReady String


type Input
    = Input ()


gameInit =
    { time = 0
    , textures = Dict.empty
    , input = Input ()
    }


initWrap init flags =
    let
        ( userInit, initCmd ) =
            init flags
    in
        ( ( gameInit, userInit ), Cmd.map User initCmd )


gameUpdate { tickFn, updateFn, textureReadyFn, textureFailedToLoadFn } msg ( gameModel, model ) =
    case msg of
        Tick dt ->
            ( { gameModel | time = gameModel.time + dt }, tickFn dt gameModel.input model ) ! []

        TextureLoaded id t ->
            let
                ( m, cmd ) =
                    updateFn (textureReadyFn id) model
            in
                ( { gameModel | textures = Dict.insert id t gameModel.textures }
                , m
                )
                    ! [ Cmd.map User cmd ]

        User msg ->
            let
                ( m, cmd ) =
                    updateFn msg model
            in
                ( gameModel, m ) ! [ Cmd.map User cmd ]

        TextureLoadFailed id ->
            let
                ( m, cmd ) =
                    updateFn (textureFailedToLoadFn id) model
            in
                ( gameModel, m ) ! [ Cmd.map User cmd ]


startWithFlags :
    { init : flags -> ( model, Cmd msg )
    , tick : Float -> Input -> model -> model
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Html msg
    , render : model -> ( Camera, List Renderable )
    , textureReady : String -> msg
    , textureFailedToLoad : String -> msg
    }
    -> Program flags
startWithFlags { subscriptions, init, tick, update, view, textureReady, textureFailedToLoad, render } =
    let
        init' =
            initWrap init

        update' =
            gameUpdate
                { tickFn = tick
                , updateFn = update
                , textureReadyFn = textureReady
                , textureFailedToLoadFn = textureFailedToLoad
                }

        subs' ( gm, m ) =
            Sub.batch [ gameSubs gm, Sub.map User (subscriptions m) ]

        view' ( gm, m ) =
            Html.div []
                [ Html.App.map User (view m)
                , gameView render ( gm, m )
                ]
    in
        programWithFlags
            { init = init'
            , update = update'
            , subscriptions = subs'
            , view = view'
            }


start :
    { init : model
    , render : model -> ( Camera, List Renderable )
    , tick : Float -> Input -> model -> model
    }
    -> Program Never
start { init, tick, render } =
    startWithFlags
        { init = \_ -> ( init, Cmd.none )
        , tick = tick
        , update =
            \msg model ->
                ( model, Cmd.none )
        , subscriptions =
            \model ->
                Sub.none
        , view =
            \model ->
                Html.text ""
        , render = render
        , textureReady =
            \id ->
                ()
        , textureFailedToLoad =
            \id ->
                ()
        }


gameView render ( gm, m ) =
    let
        ( camera, renderables ) =
            render m
    in
        Game.renderCentered gm.time ( 800, 600 ) camera renderables


gameSubs m =
    AnimationFrame.diffs Tick
