module Game.TwoD exposing (..)

import Html exposing (Html, Attribute)
import Html.Attributes as Attr
import WebGL exposing (Texture, Shader)


--

import Game.Helpers exposing (..)
import Game.TwoD.Render as Render exposing (Renderable)
import Game.TwoD.Camera as Camera exposing (Camera)


render : ( Int, Int ) -> Camera -> List Renderable -> Html Never
render =
    renderWithOptions []


renderCentered : ( Int, Int ) -> Camera -> List Renderable -> Html Never
renderCentered =
    renderCenteredWithOptions [] []


renderCenteredWithOptions :
    List (Attribute msg)
    -> List (Attribute msg)
    -> Int2
    -> Camera
    -> List Renderable
    -> Html msg
renderCenteredWithOptions containerAttributes canvasAttributes dimensions camera objects =
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
        [ renderWithOptions canvasAttributes dimensions camera objects ]


renderWithOptions : List (Attribute msg) -> Int2 -> Camera -> List Renderable -> Html msg
renderWithOptions attributes ( w, h ) camera objects =
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
            (List.map (Render.toWebGl cameraProj) objects)


makeTransform =
    Game.Helpers.makeTransform


todo =
    \_ -> Debug.crash "todo"
