module Game.TwoD.Shapes exposing (unitQube, Vertex)

{-|
# Shapes for WebGL rendering.

You don't need this module,
unless you want to have a ready made qube for a custom vertex shader.
Since we're dealing with 2d only,
the only available shape is a qube

@docs unitQube

@docs Vertex
-}

import WebGL exposing (Drawable)
import Math.Vector2 exposing (Vec2, vec2)


{-|
Just an alias for a 2d vector.
Needs to be in a record because it will be passed as an
attribute to the vertex shader
-}
type alias Vertex =
    { a_position : Vec2 }


{-|
A qube with corners (0, 0), (1, 1)
-}
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
