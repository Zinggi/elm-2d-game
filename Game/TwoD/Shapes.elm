module Game.TwoD.Shapes exposing (..)

import WebGL exposing (Drawable)
import Math.Vector2 exposing (Vec2, vec2)


type alias Vertex =
    { a_position : Vec2 }


unitQube : Drawable Vertex
unitQube =
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
