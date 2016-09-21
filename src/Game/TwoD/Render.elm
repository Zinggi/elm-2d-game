module Game.TwoD.Render
    exposing
        ( Renderable
        , rectangle
        , rectangleZ
        , rectangleWithOptions
        , sprite
        , spriteZ
        , spriteWithOptions
        , animatedSprite
        , animatedSpriteZ
        , animatedSpriteWithOptions
        , customFragment
        , veryCustom
        , MakeUniformsFunc
        , toWebGl
        )

{-|
# 2D rendering module
This module provides a way to render commonly used objects in 2d games
like simple sprites and sprite animations.

It also provides colored rectangles which can be great during prototyping.
The simple rectangles can easily be replaced by nicer looking textures later.

suggested import:

    import Game.TwoD.Render as Render exposing (Renderable)


The functions to render something all come in 3 forms:

    thing, thingZ, thingWithOptions

The first is the most common one where you can only specify
the size, the position in 2d and the color.


The second one is the same as the first, but with a 3d position.
The z position goes from -1 to 1, everything outside this will be invisible.
This can be used to put something in front or behind regardless of the render order.


The last one gives you all possible options, e.g. the rotation
, the pivot point of the rotation (normalized from 0 to 1), etc.

TODO: insert picture to visualize coordinate system.

@docs Renderable

## Rectangles
@docs rectangle
@docs rectangleZ
@docs rectangleWithOptions

### With texture

Textures are `Maybe` values because you can never have a texture at the start of your game.
You first have to load your textures. In case you pass a `Nothing` as a value for a texture,
A gray rectangle will be displayed instead.

For loading textures I suggest keeping a dictionary of textures and then use your textures
by calling `Dict.get "textureId" model.textures` as this already returns a Maybe value
, making it a perfect fit to pass for the texture parameter.

**NOTE**: Texture dimensions have to be in a power of 2, e.g. 2^n x 2^m, like 4x16, 16x16, 512x256, etc.
If you try to use a non power of two texture, WebGL will spit out a bunch of warnings and display a black rectangle.


@docs sprite
@docs spriteZ
@docs spriteWithOptions

### Animated
@docs animatedSprite
@docs animatedSpriteZ
@docs animatedSpriteWithOptions

## Custom
These are useful if you want to write your own GLSL shaders.
When writing your own shaders, you might want to look at
Game.TwoD.Shaders and Game.TwoD.Shapes for reusable parts.


@docs customFragment
@docs MakeUniformsFunc
@docs veryCustom
@docs toWebGl
-}

import Color exposing (Color)
import WebGL exposing (Texture)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3)
import Game.TwoD.Shaders exposing (..)
import Game.TwoD.Shapes exposing (unitSquare)
import Game.Helpers exposing (..)


{-|
A representation of something that can be rendered.
To actually render a `Renderable` onto a web page use the `Game.TwoD.*` functions
-}
type Renderable
    = ColoredRectangle { transform : Mat4, color : Vec3 }
    | TexturedRectangle { transform : Mat4, texture : Texture, tileWH : Vec2 }
    | AnimatedSprite { transform : Mat4, texture : Texture, bottomLeft : Vec2, topRight : Vec2, duration : Float, numberOfFrames : Int }
    | Custom ({ cameraProj : Mat4, time : Float } -> WebGL.Renderable)


{-|
Just an alias for this crazy function, needed when you want to use customFragment
-}
type alias MakeUniformsFunc a =
    { cameraProj : Mat4, time : Float, transform : Mat4 }
    -> { a | cameraProj : Mat4, transform : Mat4 }


{-|
Converts a Renderable to a WebGL.Renderable.

    toWebGl time cameraProj renderable
-}
toWebGl : Float -> Mat4 -> Renderable -> WebGL.Renderable
toWebGl time cameraProj object =
    case object of
        ColoredRectangle { transform, color } ->
            WebGL.render vertColoredRect
                fragUniColor
                unitSquare
                { transform = transform, color = color, cameraProj = cameraProj }

        TexturedRectangle { transform, texture, tileWH } ->
            WebGL.render vertTexturedRect
                fragTextured
                unitSquare
                { transform = transform, texture = texture, cameraProj = cameraProj, tileWH = tileWH }

        AnimatedSprite { transform, texture, bottomLeft, topRight, duration, numberOfFrames } ->
            WebGL.render vertTexturedRect
                fragAnimTextured
                unitSquare
                { transform = transform, texture = texture, cameraProj = cameraProj, bottomLeft = bottomLeft, topRight = topRight, duration = duration, time = time, numberOfFrames = numberOfFrames }

        Custom f ->
            f { cameraProj = cameraProj, time = time }



--renderTransparent =
--WebGL.renderWithConfig [ WebGL.Enable WebGL.Blend, WebGL.BlendFunc ( WebGL.One, WebGL.OneMinusSrcAlpha ) ]
--WebGL.renderWithConfig [ WebGL.Enable WebGL.Blend, WebGL.BlendFunc ( WebGL.SrcAlpha, WebGL.OneMinusSrcAlpha ) ]


{-|
A colored rectangle, great for prototyping
-}
rectangle : { o | color : Color, position : Float2, size : Float2 } -> Renderable
rectangle { size, position, color } =
    let
        ( x, y ) =
            position
    in
        rectangleZ { size = size, position = ( x, y, 0 ), color = color }


{-|
The same, but with 3d position.
-}
rectangleZ : { o | color : Color, position : Float3, size : Float2 } -> Renderable
rectangleZ { color, position, size } =
    rectangleWithOptions
        { color = color, position = position, size = size, rotation = 0, pivot = ( 0, 0 ) }


{-|
A colored rectangle, that can also be rotated
-}
rectangleWithOptions :
    { o | color : Color, position : Float3, size : Float2, rotation : Float, pivot : Float2 }
    -> Renderable
rectangleWithOptions { color, rotation, position, size, pivot } =
    let
        ( ( px, py ), ( w, h ), ( x, y, z ) ) =
            ( pivot, size, position )
    in
        ColoredRectangle
            { transform = makeTransform ( x, y, z ) rotation ( w, h ) ( px, py )
            , color = colorToVector color
            }


{-|
A sprite.
-}
sprite : { o | texture : Maybe Texture, position : Float2, size : Float2 } -> Renderable
sprite { texture, position, size } =
    let
        ( x, y ) =
            position
    in
        spriteZ { texture = texture, position = ( x, y, 0 ), size = size }


{-|
A sprite with 3d position
-}
spriteZ : { o | texture : Maybe Texture, position : Float3, size : Float2 } -> Renderable
spriteZ { texture, position, size } =
    spriteWithOptions
        { texture = texture, position = position, size = size, tiling = ( 1, 1 ), rotation = 0, pivot = ( 0, 0 ) }


{-|
A sprite with tiling and rotation.

    spriteWithOptions {config | tiling = (3,5)}

will create a sprite with a texture that repeats itself 3 times horizontally and 5 times vertically.
TODO: picture!
-}
spriteWithOptions :
    { o | texture : Maybe Texture, position : Float3, size : Float2, tiling : Float2, rotation : Float, pivot : Float2 }
    -> Renderable
spriteWithOptions ({ texture, position, size, tiling, rotation, pivot } as args) =
    let
        ( ( w, h ), ( x, y, z ), ( px, py ), ( tw, th ) ) =
            ( size, position, pivot, tiling )
    in
        case texture of
            Just t ->
                TexturedRectangle
                    { transform = makeTransform ( x, y, z ) (rotation) ( w, h ) ( px, py )
                    , texture = t
                    , tileWH = vec2 tw th
                    }

            Nothing ->
                rectangleZ { position = position, size = size, color = Color.grey }


{-|
An animated sprite. `bottomLeft` and `topRight` define a sub area from a texture
where the animation frames are located. It's a normalized coordinate from 0 to 1.

TODO: picture!
-}
animatedSprite :
    { o
        | texture : Maybe Texture
        , position : Float2
        , size : Float2
        , bottomLeft : Float2
        , topRight : Float2
        , numberOfFrames : Int
        , duration : Float
    }
    -> Renderable
animatedSprite ({ position } as options) =
    let
        ( x, y ) =
            position
    in
        animatedSpriteZ { options | position = ( x, y, 0 ) }


{-|
The same with 3d position
-}
animatedSpriteZ :
    { o
        | texture : Maybe Texture
        , position : Float3
        , size : Float2
        , bottomLeft : Float2
        , topRight : Float2
        , numberOfFrames : Int
        , duration : Float
    }
    -> Renderable
animatedSpriteZ { texture, duration, numberOfFrames, position, size, bottomLeft, topRight } =
    animatedSpriteWithOptions
        { texture = texture
        , position = position
        , size = size
        , bottomLeft = bottomLeft
        , topRight = topRight
        , duration = duration
        , numberOfFrames = numberOfFrames
        , rotation = 0
        , pivot = ( 0, 0 )
        }


{-| the same with rotation
-}
animatedSpriteWithOptions :
    { o
        | texture : Maybe Texture
        , position : Float3
        , size : Float2
        , bottomLeft : Float2
        , topRight : Float2
        , rotation : Float
        , pivot : Float2
        , numberOfFrames : Int
        , duration : Float
    }
    -> Renderable
animatedSpriteWithOptions { texture, position, size, bottomLeft, topRight, duration, numberOfFrames, rotation, pivot } =
    let
        ( ( x, y, z ), ( w, h ), ( blx, bly ), ( trx, try ), ( px, py ) ) =
            ( position, size, bottomLeft, topRight, pivot )
    in
        case texture of
            Nothing ->
                rectangleZ { position = position, size = size, color = Color.grey }

            Just tex ->
                AnimatedSprite
                    { transform = makeTransform ( x, y, z ) (rotation) ( w, h ) ( px, py )
                    , texture = tex
                    , bottomLeft = vec2 blx bly
                    , topRight = vec2 trx try
                    , duration = duration
                    , numberOfFrames = numberOfFrames
                    }


{-|
This allows you to write your own custom fragment shader.
The type signature may look terrifying,
but this is still easier than using veryCustom or using WebGL directly.
It handles the vertex shader for you, e.g. your object will appear at the expected location once rendered.

For the fragment shader, you have the `vec2 varying vcoord;` variable available,
which can be used to sample a texture (`texture2D(texture, vcoord);`)

The `MakeUniformsFunc` allows you to pass along any additional uniforms you may need.
This typically looks something like this:

    makeUniforms {cameraProj, transform, time} =
        {cameraProj=cameraProj, transform=transform, time=time, myUniform=someVector}

    render =
        customFragment makeUniforms { fragmentShader=frag, position=p, size=s, rotation=0, pivot=(0,0) }

    frag =
        [|glsl

    precision mediump float;

    varying vec2 vcoord;

    void main () {
      gl_FragColor = vcoord.yx;
    }
    |]

Don't pass the time along if your shader doesn't need it.
-}
customFragment :
    MakeUniformsFunc u
    -> { b
        | fragmentShader :
            WebGL.Shader {} { u | cameraProj : Mat4, transform : Mat4 } { vcoord : Vec2 }
        , pivot : Float2
        , position : Float3
        , rotation : Float
        , size : Float2
       }
    -> Renderable
customFragment makeUniforms { fragmentShader, position, size, rotation, pivot } =
    let
        ( ( x, y, z ), ( w, h ), ( px, py ) ) =
            ( position, size, pivot )
    in
        Custom
            (\{ cameraProj, time } ->
                WebGL.render vertTexturedRect
                    fragmentShader
                    unitSquare
                    (makeUniforms
                        { transform = makeTransform ( x, y, z ) (rotation) ( w, h ) ( px, py )
                        , cameraProj = cameraProj
                        , time = time
                        }
                    )
            )


{-|
This allows you to specify your own attributes, vertex shader and fragment shader by using the WebGL library directly.
If you use this you have to calculate your transformations yourself.

If you need a quad as attributes, you can take the one from Game.TwoD.Shapes

TODO: Expose make transform

    veryCustom (\{cameraProj, time} ->
        WebGL.render vert frag Shapes.unitSquare
          { u_crazyFrog=frogTexture
          , transform=transform
          , camera=cameraProj
          }
    )
-}
veryCustom : ({ cameraProj : Mat4, time : Float } -> WebGL.Renderable) -> Renderable
veryCustom =
    Custom
