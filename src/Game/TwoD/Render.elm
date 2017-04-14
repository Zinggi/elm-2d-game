module Game.TwoD.Render
    exposing
        ( Renderable
        , BasicShape
        , rectangle
        , triangle
        , circle
        , ring
        , shape
        , shapeZ
        , shapeWithOptions
        , sprite
        , spriteZ
        , spriteWithOptions
        , animatedSprite
        , animatedSpriteZ
        , animatedSpriteWithOptions
        , manuallyManagedAnimatedSpriteWithOptions
        , customFragment
        , veryCustom
        , MakeUniformsFunc
        , parallaxScroll
        , parallaxScrollWithOptions
        , toWebGl
        , renderTransparent
        )

{-|


# 2D rendering module

This module provides a way to render commonly used objects in 2d games
like simple sprites and sprite animations.

It also provides colored shapes which can be great during prototyping.
The simple shapes can easily be replaced by nicer looking textures later.

suggested import:

    import Game.TwoD.Render as Render exposing (Renderable)

Most functions to render something come in 3 forms:

    thing, thingZ, thingWithOptions

The first is the most common one where you can specify
the size, the position in 2d and some more.

The second one is the same as the first, but with a 3d position.
The z position goes from -1 to 1, everything outside this will be invisible.
This can be used to put something in front or behind regardless of the render order.

The last one gives you all possible options, e.g. the rotation
, the pivot point of the rotation (normalized from 0 to 1), etc.

TODO: insert picture to visualize coordinate system.

@docs Renderable


## Basic Shapes

@docs shape
@docs BasicShape, rectangle, triangle, circle, ring
@docs shapeZ, shapeWithOptions


### With texture

Textures are `Maybe` values because you can never have a texture at the start of your game.
You first have to load your textures. In case you pass a `Nothing` as a value for a texture,
A gray rectangle will be displayed instead.

For loading textures I suggest using the [game-resources library](http://package.elm-lang.org/packages/Zinggi/elm-game-resources/latest).

**NOTE**: Texture dimensions should be a power of 2, e.g. (2^n)x(2^m), like 4x16, 16x16, 512x256, etc.
Non power of two texture are possible, but [not encouraged](http://package.elm-lang.org/packages/elm-community/webgl/latest/WebGL-Texture#Error).

@docs sprite, spriteZ, spriteWithOptions


### Animated

@docs animatedSprite, animatedSpriteZ, animatedSpriteWithOptions, manuallyManagedAnimatedSpriteWithOptions


### Background

@docs parallaxScroll, parallaxScrollWithOptions


## Custom

These are useful if you want to write your own GLSL shaders.
When writing your own shaders, you might want to look at
Game.TwoD.Shaders and Game.TwoD.Shapes for reusable parts.

@docs customFragment
@docs MakeUniformsFunc
@docs veryCustom
@docs renderTransparent
@docs toWebGl

-}

import Color exposing (Color)
import WebGL exposing (Texture)
import WebGL.Settings.Blend as Blend
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as V2 exposing (Vec2, vec2)
import Game.TwoD.Shaders exposing (..)
import Game.TwoD.Shapes exposing (unitSquare, unitTriangle)
import Game.TwoD.Camera as Camera exposing (Camera)
import Game.Helpers as Helpers exposing (..)


{-| A representation of something that can be rendered.
To actually render a `Renderable` onto a web page use the `Game.TwoD.*` functions
-}
type Renderable
    = Renderable ({ camera : Camera, screenSize : ( Float, Float ), time : Float } -> WebGL.Entity)


{-| A representation of a basic shape to use when rendering a ColoredShape
-}
type BasicShape
    = Rectangle
    | Triangle
    | Circle
    | Ring


{-| BasicShape constructor for a rectangle
-}
rectangle : BasicShape
rectangle =
    Rectangle


{-| BasicShape constructor for a triangle
-}
triangle : BasicShape
triangle =
    Triangle


{-| BasicShape constructor for a circle
-}
circle : BasicShape
circle =
    Circle


{-| BasicShape constructor for a ring
-}
ring : BasicShape
ring =
    Ring


{-| Converts a Renderable to a WebGL.Entity.
You don't need this unless you want to slowly introduce
this library in a project that currently uses WebGL directly.

    toWebGl time camera (w, h) renderable

-}
toWebGl : Float -> Camera -> Float2 -> Renderable -> WebGL.Entity
toWebGl time camera screenSize (Renderable f) =
    f { camera = camera, screenSize = screenSize, time = time }


{-| This can be used inside `veryCustom` instead of `WebGL.entity`.
It's a customized blend function that works well with textures with alpha.
-}
renderTransparent : WebGL.Shader attributes uniforms varyings -> WebGL.Shader {} uniforms varyings -> WebGL.Mesh attributes -> uniforms -> WebGL.Entity
renderTransparent =
    WebGL.entityWith
        [ Blend.custom
            { r = 0
            , g = 0
            , b = 0
            , a = 0
            , color = Blend.customAdd Blend.srcAlpha Blend.oneMinusSrcAlpha
            , alpha = Blend.customAdd Blend.one Blend.oneMinusSrcAlpha
            }
        ]


{-| A colored shape, great for prototyping
-}
shape : BasicShape -> { o | color : Color, position : Float2, size : Float2 } -> Renderable
shape shape { size, position, color } =
    let
        ( x, y ) =
            position
    in
        shapeZ shape { size = size, position = ( x, y, 0 ), color = color }


{-| The same, but with 3d position.
-}
shapeZ : BasicShape -> { o | color : Color, position : Float3, size : Float2 } -> Renderable
shapeZ shape { color, position, size } =
    shapeWithOptions
        shape
        { color = color, position = position, size = size, rotation = 0, pivot = ( 0, 0 ) }


{-| A colored shape, that can also be rotated
-}
shapeWithOptions :
    BasicShape
    -> { o | color : Color, position : Float3, size : Float2, rotation : Float, pivot : Float2 }
    -> Renderable
shapeWithOptions shape { color, rotation, position, size, pivot } =
    let
        ( frag, attribs ) =
            case shape of
                Rectangle ->
                    ( fragUniColor, unitSquare )

                Triangle ->
                    ( fragUniColor, unitTriangle )

                Circle ->
                    ( fragUniColorCircle, unitSquare )

                Ring ->
                    ( fragUniColorRing, unitSquare )
    in
        veryCustom
            (\{ camera, screenSize } ->
                renderTransparent vertColoredShape
                    frag
                    attribs
                    { transform = makeTransform position rotation size pivot
                    , color = colorToRGBVector color
                    , cameraProj = Camera.view camera screenSize
                    }
            )


{-| A sprite.
-}
sprite : { o | texture : Maybe Texture, position : Float2, size : Float2 } -> Renderable
sprite { texture, position, size } =
    let
        ( x, y ) =
            position
    in
        spriteZ { texture = texture, position = ( x, y, 0 ), size = size }


{-| A sprite with 3d position
-}
spriteZ : { o | texture : Maybe Texture, position : Float3, size : Float2 } -> Renderable
spriteZ { texture, position, size } =
    spriteWithOptions
        { texture = texture, position = position, size = size, tiling = ( 1, 1 ), rotation = 0, pivot = ( 0, 0 ) }


{-| A sprite with tiling and rotation.

    spriteWithOptions {config | tiling = (3,5)}

will create a sprite with a texture that repeats itself 3 times horizontally and 5 times vertically.
TODO: picture!

-}
spriteWithOptions :
    { o | texture : Maybe Texture, position : Float3, size : Float2, tiling : Float2, rotation : Float, pivot : Float2 }
    -> Renderable
spriteWithOptions ({ texture, position, size, tiling, rotation, pivot } as args) =
    case texture of
        Just t ->
            veryCustom
                (\{ camera, screenSize } ->
                    rectWithFragment fragTextured
                        { transform = makeTransform position rotation size pivot
                        , texture = t
                        , tileWH = V2.fromTuple tiling
                        , cameraProj = Camera.view camera screenSize
                        }
                )

        Nothing ->
            shapeZ Rectangle { position = position, size = size, color = Color.grey }


rectWithFragment : WebGL.Shader {} { u | cameraProj : Mat4, transform : Mat4 } { vcoord : Vec2 } -> { u | cameraProj : Mat4, transform : Mat4 } -> WebGL.Entity
rectWithFragment frag uniforms =
    renderTransparent vertTexturedRect frag unitSquare uniforms


{-| An animated sprite. `bottomLeft` and `topRight` define a sub area from a texture
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


{-| The same with 3d position
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
    case texture of
        Just tex ->
            veryCustom
                (\{ camera, screenSize, time } ->
                    rectWithFragment fragAnimTextured
                        { transform = makeTransform position rotation size pivot
                        , texture = tex
                        , bottomLeft = V2.fromTuple bottomLeft
                        , topRight = V2.fromTuple topRight
                        , duration = duration
                        , numberOfFrames = numberOfFrames
                        , cameraProj = Camera.view camera screenSize
                        , time = time
                        }
                )

        Nothing ->
            shapeZ Rectangle { position = position, size = size, color = Color.grey }


{-| The same as animated sprite, but you control what frame to display.
-}
manuallyManagedAnimatedSpriteWithOptions :
    { o
        | texture : Maybe Texture
        , position : Float3
        , size : Float2
        , bottomLeft : Float2
        , topRight : Float2
        , rotation : Float
        , pivot : Float2
        , numberOfFrames : Int
        , currentFrame : Int
    }
    -> Renderable
manuallyManagedAnimatedSpriteWithOptions { texture, position, size, bottomLeft, topRight, numberOfFrames, currentFrame, rotation, pivot } =
    case texture of
        Just tex ->
            veryCustom
                (\{ camera, screenSize } ->
                    rectWithFragment fragManualAnimTextured
                        { transform = makeTransform position rotation size pivot
                        , texture = tex
                        , bottomLeft = V2.fromTuple bottomLeft
                        , topRight = V2.fromTuple topRight
                        , numberOfFrames = numberOfFrames
                        , currentFrame = currentFrame
                        , cameraProj = Camera.view camera screenSize
                        }
                )

        Nothing ->
            shapeZ Rectangle { position = position, size = size, color = Color.grey }


{-| Used for scrolling backgrounds.
This probably wont satisfy all possible needs for a scrolling background,
but it can give you something that looks nice quickly.
-}
parallaxScroll : { o | scrollSpeed : Float2, z : Float, tileWH : Float2, texture : Maybe Texture } -> Renderable
parallaxScroll { scrollSpeed, tileWH, texture, z } =
    parallaxScrollWithOptions { scrollSpeed = scrollSpeed, tileWH = tileWH, texture = texture, z = z, offset = ( 0.5, 0.5 ) }


{-| Same but with an offset parameter that you can use to position the background.
-}
parallaxScrollWithOptions : { o | scrollSpeed : Float2, z : Float, tileWH : Float2, offset : Float2, texture : Maybe Texture } -> Renderable
parallaxScrollWithOptions { scrollSpeed, tileWH, texture, z, offset } =
    case texture of
        Nothing ->
            shapeZ Rectangle { position = ( 0, 0, z ), size = ( 1, 1 ), color = Color.grey }

        Just t ->
            veryCustom
                (\{ camera, screenSize } ->
                    renderTransparent vertParallaxScroll
                        fragTextured
                        unitSquare
                        { scrollSpeed = V2.fromTuple scrollSpeed
                        , z = z
                        , tileWH = V2.fromTuple tileWH
                        , texture = t
                        , offset = V2.fromTuple offset
                        , cameraPos = V2.fromTuple (Camera.getPosition camera)
                        , cameraSize = V2.fromTuple (Camera.getViewSize screenSize camera)
                        }
                )


{-| Just an alias, needed when you want to use customFragment
-}
type alias MakeUniformsFunc a =
    { cameraProj : Mat4, time : Float, transform : Mat4 }
    -> { a | cameraProj : Mat4, transform : Mat4 }


{-| This allows you to write your own custom fragment shader.
To learn about writing shaders, I recommend [this free book](https://thebookofshaders.com/00/).

The type signature may look terrifying,
but this is still easier than using veryCustom or using WebGL directly.
It handles the vertex shader for you, e.g. your object will appear at the expected location once rendered.

For the fragment shader, you have the `vec2 varying vcoord;` variable available,
which can be used to sample a texture (`texture2D(texture, vcoord);`).
It's a vector that goes from (0,0) to (1,1)

The `MakeUniformsFunc` allows you to pass along any additional uniforms you may need.
In practice, this might look something like this:

    makeUniforms { cameraProj, transform, time } =
        { cameraProj = cameraProj, transform = transform, time = time, myUniform = someVector }

    render =
        customFragment makeUniforms
            { fragmentShader = frag, position = p, size = s, rotation = 0, pivot = ( 0, 0 ) }

    frag =
        [glsl|

    precision mediump float;

    varying vec2 vcoord;
    uniform vec2 myUniform;

    void main () {
      gl_FragColor = vcoord.yx + myUniform;
    }
    |]

Don't pass the time along if your shader doesn't need it.

Here is a small example that draws a circle:
<https://ellie-app.com/LSTb2NnkDWa1/0>

-}
customFragment :
    MakeUniformsFunc u
    ->
        { b
            | fragmentShader :
                WebGL.Shader {} { u | cameraProj : Mat4, transform : Mat4 } { vcoord : Vec2 }
            , pivot : Float2
            , position : Float3
            , rotation : Float
            , size : Float2
        }
    -> Renderable
customFragment makeUniforms { fragmentShader, position, size, rotation, pivot } =
    Renderable
        (\{ camera, screenSize, time } ->
            renderTransparent vertTexturedRect
                fragmentShader
                unitSquare
                (makeUniforms
                    { transform = makeTransform position rotation size pivot
                    , cameraProj = Camera.view camera screenSize
                    , time = time
                    }
                )
        )


{-| This allows you to specify your own attributes, vertex shader and fragment shader by using the WebGL library directly.
If you use this you have to calculate the transformations yourself. (You can use Shaders.makeTransform)

If you need a square as attributes, you can take the one from Game.TwoD.Shapes

    veryCustom (\{camera, screenSize, time} ->
        WebGL.entity myVert myFrag Shapes.unitSquare
          { u_crazyFrog = frogTexture
          , transform = Shaders.makeTransform (x, y, z) 0 (2, 4) (0, 0)
          , cameraProj = Camera.view camera screenSize
          }
    )

-}
veryCustom : ({ camera : Camera, screenSize : ( Float, Float ), time : Float } -> WebGL.Entity) -> Renderable
veryCustom =
    Renderable
