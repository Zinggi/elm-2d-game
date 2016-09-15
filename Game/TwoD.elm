module Game.TwoD exposing (..)

import Html exposing (Html, Attribute)
import Html.Attributes as Attr
import Color exposing (Color)
import WebGL
import Math.Matrix4 as M4 exposing (Mat4)
import Math.Vector3 as V3 exposing (Vec3, vec3)


--

import Game.TwoD.Object as Object exposing (Object)
import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD.Shapes as Shapes exposing (Vertex)


type RenderObject
    = ColoredRectangle
        { transform : Mat4
        , color : Vec3
        }


render : ( Int, Int ) -> Camera -> List RenderObject -> Html Never
render =
    renderWithOptions []


renderCentered : ( Int, Int ) -> Camera -> List RenderObject -> Html Never
renderCentered =
    renderCenteredWithOptions [] []


renderCenteredWithOptions :
    List (Attribute msg)
    -> List (Attribute msg)
    -> ( Int, Int )
    -> Camera
    -> List RenderObject
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


renderWithOptions : List (Attribute msg) -> ( Int, Int ) -> Camera -> List RenderObject -> Html msg
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
            (List.map (renderWebGl cameraProj) objects)


renderWebGl : Mat4 -> RenderObject -> WebGL.Renderable
renderWebGl cameraProj object =
    case object of
        ColoredRectangle { transform, color } ->
            WebGL.render vertPoly
                fragUniColor
                Shapes.unitQube
                { transform = transform, color = color, cameraProj = cameraProj }


renderObject : Object a -> RenderObject
renderObject ({ color } as object) =
    ColoredRectangle
        { transform = (getWorldTransform object)
        , color = color
        }


renderRectangle : ( Float, Float ) -> ( Float, Float, Float ) -> Color -> RenderObject
renderRectangle ( w, h ) ( x, y, z ) c =
    ColoredRectangle
        { transform = makeTransform ( x, y, z ) (0) ( w, h ) ( 0, 0 )
        , color = Object.colorToVector c
        }


getWorldTransform : Object a -> Mat4
getWorldTransform { position, rotation, scale, pivot } =
    (M4.makeTranslate (position `V3.add` (mul3 scale pivot)))
        `M4.mul` (M4.makeRotate rotation (vec3 0 0 1))
        `M4.mul` (M4.makeScale scale)
        `M4.mul` (M4.makeTranslate (V3.scale -1 pivot))


makeTransform : ( Float, Float, Float ) -> Float -> ( Float, Float ) -> ( Float, Float ) -> Mat4
makeTransform ( x, y, z ) rotation ( w, h ) ( px, py ) =
    (M4.makeTranslate ((vec3 x y z) `V3.add` (vec3 (w * px) (h * py) 0)))
        `M4.mul` (M4.makeRotate rotation (vec3 0 0 1))
        `M4.mul` (M4.makeScale (vec3 w h 1))
        `M4.mul` (M4.makeTranslate (vec3 -px -py 0))


mul3 v1 v2 =
    let
        ( ( x1, y1, z1 ), ( x2, y2, z2 ) ) =
            ( V3.toTuple v1, V3.toTuple v2 )
    in
        vec3 (x1 * x2) (y1 * y2) (z1 * z2)


vertPoly : WebGL.Shader Vertex { a | transform : Mat4, cameraProj : Mat4 } {}
vertPoly =
    [glsl|

// the coordiantes of our box
attribute vec2 a_position;
uniform mat4 transform;
uniform mat4 cameraProj;

// varying vec3 v_color;
void main() {

    vec4 pos = cameraProj*transform*vec4(a_position, 0, 1);
    gl_Position = pos;
}
|]


fragUniColor : WebGL.Shader {} { a | color : Vec3 } {}
fragUniColor =
    [glsl|

// fragment shaders don't have a default precision so we need
// to pick one. mediump is a good default. It means "medium precision"
precision mediump float;

uniform vec3 color;
//varying vec3 v_color;

void main() {
    gl_FragColor = vec4(color, 1);
}
|]
