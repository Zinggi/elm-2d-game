module Game.TwoD.Shapes exposing (unitSquare, unitTriangle, Vertex)

{-|
# Shapes for WebGL rendering.

You don't need this module,
unless you want to have a ready made square for a custom vertex shader.

Pretty much anything can be created using a single square.
If you don't believe me, see [here](http://iquilezles.org/index.html).

@docs unitSquare
@docs unitTriangle

@docs Vertex
-}

import WebGL exposing (Mesh)
import Math.Vector2 exposing (Vec2, vec2)


{-|
Just an alias for a 2d vector.
Needs to be in a record because it will be passed as an
attribute to the vertex shader
-}
type alias Vertex =
    { position : Vec2 }


{-|
A square with corners (0, 0), (1, 1)
-}
unitSquare : Mesh Vertex
unitSquare =
    WebGL.triangles
        [ ( Vertex (vec2 0 0)
          , Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          )
        , ( Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          , Vertex (vec2 1 1)
          )
        ]


{-|
A triangle with corners (0, 0), (0, 1), (1, 0)
-}
unitTriangle : Mesh Vertex
unitTriangle =
    WebGL.triangles
        [ ( Vertex (vec2 0 0)
          , Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          )
        ]
