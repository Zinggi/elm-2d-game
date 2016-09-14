module Main exposing (..)

import Html.App exposing (program)
import Html exposing (..)
import Html.Attributes exposing (..)
import Math.Vector2 as V2 exposing (..)
import Math.Vector3 as V3 exposing (..)
import Math.Vector4 as V4 exposing (..)
import Math.Matrix4 as M4 exposing (..)
import WebGL
import Camera exposing (Camera)


type alias Model =
    { camera : Camera
    }


init =
    { camera = Camera.init (vec2 0 0) 10
    }


triangle =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0)
          , Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          )
        ]


box =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0)
          , Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          )
        , ( Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          , Vertex (vec2 1 1)
          )
        ]


type alias Sprite =
    { position : Vec3
    , rotation : Float
    , pivot : Vec3
    , scale : Vec3
    , color : Vec3
    }


makeSprite ( w, h ) position color =
    { position = position
    , rotation = 0
    , pivot = vec3 (0.5) (0.5) 0
    , scale = vec3 w h 1
    , color = color
    }


makeRotatedSprite ( w, h ) position r ( px, py ) color =
    { position = position
    , rotation = 2 * pi * r
    , pivot = vec3 px py 0
    , scale = vec3 w h 1
    , color = color
    }


makeTranformWithPivot { position, rotation, pivot, scale } =
    makeTranslate (V3.scale -1 pivot)
        |> rotate rotation (vec3 0 0 1)
        |> translate pivot
        |> M4.scale scale
        |> translate position


makeTranform { position, rotation, scale, pivot } =
    (makeTranslate (position `V3.add` (mul3 scale pivot)))
        `M4.mul` (makeRotate rotation (vec3 0 0 1))
        `M4.mul` (makeScale scale)
        `M4.mul` (makeTranslate (V3.scale -1 pivot))
        |> Debug.log "transform"


mul3 v1 v2 =
    let
        ( ( x1, y1, z1 ), ( x2, y2, z2 ) ) =
            ( V3.toTuple v1, V3.toTuple v2 )
    in
        vec3 (x1 * x2) (y1 * y2) (z1 * z2)


makeRenderable dim camera ({ color } as sprite) =
    { transform = (Camera.makeProjectionMatrix dim camera) `M4.mul` (makeTranform sprite)
    , color = color
    }


update _ m =
    m ! []


type alias Vertex =
    { a_position : Vec2 }


render dim m =
    [ renderSprite dim m.camera <| makeSprite ( 1, 1 ) (vec3 0 0 0) (vec3 1 0 0)
    , renderSprite dim m.camera <| makeSprite ( 1, 2 ) (vec3 -2 -1 0) (vec3 0 0 1)
    , renderSprite dim m.camera <| makeRotatedSprite ( 3, 0.02 ) (vec3 0 -0.01 0) (1 / 4) ( 0, 0.5 ) (vec3 0 0 0)
    , renderSprite dim m.camera <| makeRotatedSprite ( 3, 0.02 ) (vec3 0 -0.01 0) (0) ( 0, 0.5 ) (vec3 0 0 0)
    ]


renderSprite dim camera sprite =
    let
        renderable =
            makeRenderable dim camera sprite
    in
        WebGL.render vertexShader fragmentShader box renderable



-- vertexShader : WebGL.Shader Vertex Sprite {}


vertexShader =
    [glsl|

// the coordiantes of our box
attribute vec2 a_position;
uniform mat4 transform;

// varying vec3 v_color;
void main() {

    //v_color = vec3(a_position, 0);
    vec4 pos = transform*vec4(a_position, 0, 1);
    gl_Position = pos;
}
|]



-- fragmentShader : WebGL.Shader {} Sprite {}


fragmentShader =
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


view m =
    div
        [ style
            [ ( "width", "100%" )
            , ( "height", "100%" )
            , ( "background-color", "aliceblue" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            ]
        ]
        [ WebGL.toHtml
            [ width 800
            , height 600
            , style
                [ ( "border", "cadetblue" )
                , ( "border-style", "solid" )
                ]
            ]
            (render ( 800, 600 ) m)
        ]


main =
    program
        { view = view
        , update = update
        , init = init ! []
        , subscriptions = (\_ -> Sub.none)
        }
