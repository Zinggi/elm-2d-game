module Game.TwoD
    exposing
        ( render
        , renderWithOptions
        , renderCentered
        , renderCenteredWithOptions
        )

{-|
A set of functions used to embed a 2d game into a webpage.
These functions specify the size and attributes passed to the canvas element.

You need to pass along the time, size and camera, as these are needed for rendering.

## Canvas element only
@docs render
@docs renderWithOptions

## Embedded in a div
@docs renderCentered
@docs renderCenteredWithOptions
-}

import Html exposing (Html, Attribute)
import Html.Attributes as Attr
import WebGL exposing (Texture, Shader)
import Math.Matrix4 exposing (Mat4)


--

import Game.Helpers exposing (..)
import Game.TwoD.Render as Render exposing (Renderable)
import Game.TwoD.Camera as Camera exposing (Camera)


{-|
Creates a canvas element that renders the given renderables

    render time (800, 600) state.camera
        [ Background.render
        , Player.render state.Player
        ]
-}
render : Float -> ( Int, Int ) -> Camera a -> List Renderable -> Html x
render =
    renderWithOptions []


{-|
Same as above, but you can specify additional attributes that will be passed to the canvas element
-}
renderWithOptions : List (Attribute msg) -> Float -> Int2 -> Camera a -> List Renderable -> Html msg
renderWithOptions attributes time ( w, h ) camera objects =
    let
        cameraProj =
            (Camera.getProjectionMatrix ( toFloat w, toFloat h ) camera)
    in
        WebGL.toHtml
            ([ Attr.width w
             , Attr.height h
             ]
                ++ attributes
            )
            (List.map (Render.toWebGl time cameraProj) objects)


{-|
Same as above, but wrapped in a div and nicely centered on the page using flexbox
-}
renderCentered : Float -> ( Int, Int ) -> Camera a -> List Renderable -> Html x
renderCentered =
    renderCenteredWithOptions [] []


{-|
Same as above, but you can specify attributes for the container div and the canvas.

    renderCenteredWithOptions
        containerAttributes canvasAttributes time dimensions camera renderables
-}
renderCenteredWithOptions :
    List (Attribute msg)
    -> List (Attribute msg)
    -> Float
    -> Int2
    -> Camera a
    -> List Renderable
    -> Html msg
renderCenteredWithOptions containerAttributes canvasAttributes time dimensions camera objects =
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
        [ renderWithOptions canvasAttributes time dimensions camera objects ]


makeTransform : Float3 -> Float -> Float2 -> Float2 -> Mat4
makeTransform =
    Game.Helpers.makeTransform
