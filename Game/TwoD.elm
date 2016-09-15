module Game.TwoD exposing (..)

import Html exposing (Html, Attribute)
import Html.Attributes as Attr
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


render : ( Int, Int ) -> Camera -> List Object -> Html Never
render =
    renderWithOptions []


renderCentered : ( Int, Int ) -> Camera -> List Object -> Html Never
renderCentered =
    renderCenteredWithOptions [] []


renderCenteredWithOptions :
    List (Attribute msg)
    -> List (Attribute msg)
    -> ( Int, Int )
    -> Camera
    -> List Object
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


renderWithOptions : List (Attribute msg) -> ( Int, Int ) -> Camera -> List Object -> Html msg
renderWithOptions attributes ( w, h ) camera objects =
    WebGL.toHtml
        ([ Attr.width w
         , Attr.height h
         ]
            ++ attributes
        )
        (renderColoredRectangles ( toFloat w, toFloat h ) camera objects)


renderColoredRectangles : ( Float, Float ) -> Camera -> List Object -> List WebGL.Renderable
renderColoredRectangles dim camera rectangles =
    let
        cameraProj =
            (Camera.makeProjectionMatrix dim camera)
    in
        List.map (renderObject cameraProj) rectangles


renderObject : Mat4 -> Object -> WebGL.Renderable
renderObject cameraProj object =
    case makeRenderable cameraProj object of
        ColoredRectangle renderable ->
            WebGL.render vertPoly fragUniColor Shapes.unitQube renderable


makeRenderable : Mat4 -> Object -> RenderObject
makeRenderable cameraProj ({ color } as object) =
    ColoredRectangle
        { transform = cameraProj `M4.mul` (getWorldTransform object)
        , color = color
        }


getWorldTransform : Object -> Mat4
getWorldTransform { position, rotation, scale, pivot } =
    (M4.makeTranslate (position `V3.add` (mul3 scale pivot)))
        `M4.mul` (M4.makeRotate rotation (vec3 0 0 1))
        `M4.mul` (M4.makeScale scale)
        `M4.mul` (M4.makeTranslate (V3.scale -1 pivot))


mul3 v1 v2 =
    let
        ( ( x1, y1, z1 ), ( x2, y2, z2 ) ) =
            ( V3.toTuple v1, V3.toTuple v2 )
    in
        vec3 (x1 * x2) (y1 * y2) (z1 * z2)


vertPoly : WebGL.Shader Vertex { a | transform : Mat4 } {}
vertPoly =
    [glsl|

// the coordiantes of our box
attribute vec2 a_position;
uniform mat4 transform;

// varying vec3 v_color;
void main() {

    vec4 pos = transform*vec4(a_position, 0, 1);
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
