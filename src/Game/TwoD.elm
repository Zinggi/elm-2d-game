module Game.TwoD
    exposing
        ( render
        , renderWithOptions
        , renderCentered
        , renderCenteredWithOptions
        , RenderConfig
        )

{-|
A set of functions used to embed a 2d game into a web page.
These functions specify the size and attributes passed to the canvas element.

You need to pass along the time, size and camera, as these are needed for rendering.

suggested import:

    import Game.TwoD as Game

@docs RenderConfig

## Canvas element only
@docs render
@docs renderWithOptions

## Embedded in a div
@docs renderCentered
@docs renderCenteredWithOptions
-}

import Html exposing (Html, Attribute)
import Html.Attributes as Attr
import WebGL


--

import Game.TwoD.Render as Render exposing (Renderable)
import Game.TwoD.Camera as Camera exposing (Camera)


{-|
This is used by all the functions below, it represents all the shared state needed to render stuff.
If you don't use sprite animations you can use `0` for the time parameter.
-}
type alias RenderConfig =
    { time : Float, size : ( Int, Int ), camera : Camera }


{-|
Creates a canvas element that renders the given Renderables.

If you don't use animated sprites, you can use `0` for the time parameter.

    render { time = time, size = (800, 600), camera = state.camera }
        [ Background.render
        , Player.render state.Player
        ]
-}
render : RenderConfig -> List Renderable -> Html x
render =
    renderWithOptions []


{-|
Same as above, but you can specify additional attributes that will be passed to the canvas element.
A useful trick to save some GPU processing at the cost of image quality is
to use a smaller `size` argument and than scale the canvas with CSS. e.g.

    renderWithOptions [style [("width", "800px"), ("height", "600px")]]
        { time = time, size = (400, 300), camera = camera }
        (World.render model.world)
-}
renderWithOptions : List (Attribute msg) -> RenderConfig -> List Renderable -> Html msg
renderWithOptions attributes { time, size, camera } objects =
    let
        ( w, h ) =
            size

        ( wf, hf ) =
            ( toFloat w, toFloat h )
    in
        WebGL.toHtmlWith
            -- TODO: Do we need the depth buffer? Is antialiasing actually desirable?
            [ WebGL.alpha False, WebGL.depth 1, WebGL.antialias ]
            ([ Attr.width w
             , Attr.height h
             ]
                ++ attributes
            )
            (List.map (Render.toWebGl time camera ( wf, hf )) objects)


{-|
Same as `render`, but wrapped in a div and nicely centered on the page using flexbox
-}
renderCentered : RenderConfig -> List Renderable -> Html x
renderCentered =
    renderCenteredWithOptions [] []


{-|
Same as above, but you can specify attributes for the container div and the canvas.

    renderCenteredWithOptions
        containerAttributes
        canvasAttributes
        renderConfig
        renderables
-}
renderCenteredWithOptions :
    List (Attribute msg)
    -> List (Attribute msg)
    -> RenderConfig
    -> List Renderable
    -> Html msg
renderCenteredWithOptions containerAttributes canvasAttributes renderConfig objects =
    Html.div
        ([ Attr.style
            [ ( "width", "100%" )
            , ( "height", "100%" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            ]
         ]
            ++ containerAttributes
        )
        [ renderWithOptions canvasAttributes renderConfig objects ]
