#Game.TwoD


A set of functions used to embed a 2d game into a webpage.
These functions specify the size and attributes passed to the canvas element.

You need to pass along the time, size and camera, as these are needed for rendering.

suggested import:

    import Game.TwoD as Game

## Canvas element only
```elm
render : Float
    -> ( Int, Int ) -> Game.TwoD.Camera.Camera a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html x
```

Creates a canvas element that renders the given renderables.

If you don't use animated sprites, you can use `0` for the time parameter.

    render time (800, 600) state.camera
        [ Background.render
        , Player.render state.Player
        ]

---

```elm
renderWithOptions : List (Html.Attribute msg)
    -> Float
    -> Game.Helpers.Int2
    -> Game.TwoD.Camera.Camera a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify additional attributes that will be passed to the canvas element.
A usefull trick to save some gpu processing at the cost of image quality is
to use a smaller `size` argument and than scale the canvas with css. e.g.

    renderWithOptions [style [("width", "800px"), ("height", "600px")]]
        time (400, 300) camera
        (World.render model.world)

---


## Embedded in a div
```elm
renderCentered : Float
    -> ( Int, Int ) -> Game.TwoD.Camera.Camera a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html x
```

Same as `render`, but wrapped in a div and nicely centered on the page using flexbox

---

```elm
renderCenteredWithOptions : List (Html.Attribute msg)
    -> List (Html.Attribute msg)
    -> Float
    -> Game.Helpers.Int2
    -> Game.TwoD.Camera.Camera a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify attributes for the container div and the canvas.

    renderCenteredWithOptions
        containerAttributes
        canvasAttributes
        time dimensions camera
        renderables

---



---

#Game.TwoD.Render


# 2D rendering module
This module provides a way to render commonly used objects in 2d games
like simple sprites and sprite animations.

It also provides colored recangels which can be great during prototyping.
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

```elm
type Renderable
    = Renderable
```

A representation of something that can be rendered.
To actually render a `Renderable` onto a webpage use the `Game.TwoD.*` functions

---


## Rectangles
```elm
rectangle : { o | color : Color.Color, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, great for prototyping

---

```elm
rectangleZ : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

The same, but with 3d position.

---

```elm
rectangleWithOptions : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, that can also be rotated

---


### With texture

Textures are `Maybe` values because you can never have a texture at the start of your game.
You first have to load your textures. In case you pass a `Nothing` as a value for a texture,
A gray rectangle will be displayed instead.

For loading textures I suggest keeping a dictionary of textures and then use your textures
by calling `Dict.get "textureId" model.textures` as this already returns a Maybe value
, making it a perfect fit to pass for the texture parameter.


```elm
sprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite.

---

```elm
spriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with 3d position

---

```elm
spriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, tiling : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with tiling and rotation.

    spriteWithOptions {config | tiling = (3,5)}

will create a sprite with a texture that reapeats itself 3 times horizontally and 5 times vertically.
TODO: picture!

---


### Animated
```elm
animatedSprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

An animated sprite. `bottomLeft` and `topRight` define a sub area from a texture
where the animation frames are located. It's a normalized coordinate from 0 to 1.

TODO: picture!

---

```elm
animatedSpriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

The same with 3d position

---

```elm
animatedSpriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

the same with rotation

---


## Custom
These are usefull if you want to write your own GLSL shaders.
When writing your own shaders, you might want to look at
Game.TwoD.Shaders and Game.TwoD.Shapes for reusable parts.


```elm
customFragment : Game.TwoD.Render.MakeUniformsFunc u
    -> { b | fragmentShader : WebGL.Shader {} { u | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }, pivot : Game.Helpers.Float2, position : Game.Helpers.Float3, rotation : Float, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

This allows you to write your own custom fragment shader.
The type signature may look terrifying,
but this is still easier than using veryCustom or using WebGL directely.
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

---

```elm
type alias MakeUniformsFunc = 
  { cameraProj : Math.Matrix4.Mat4 , time : Float , transform : Math.Matrix4.Mat4 } -> { a | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 }
```

Just an alias for this crazy function, needed when you want to use customFragment

---

```elm
veryCustom : ({ cameraProj : Math.Matrix4.Mat4, time : Float } -> WebGL.Renderable) -> Game.TwoD.Render.Renderable
```

This allows you to specify your own attributes, vertex shader and fragment shader by using the WebGL library directely.
If you use this you have to calculate your transformtions yourself.

If you need a quad as attributes, you can take the one from Game.TwoD.Shapes

    veryCustom (\{cameraProj, time} ->
        WebGL.render vert frag Shapes.unitQube
          { u_crazyFrog=frogTexture
          , transform=transform
          , camera=cameraProj
          }
    )

---

```elm
toWebGl : Float
    -> Math.Matrix4.Mat4
    -> Game.TwoD.Render.Renderable
    -> WebGL.Renderable
```

Converts a @docs Renderable to a @docs WebGL.Renderable.

    toWebGl time cameraProj renderable

---



---

#Game.TwoD.Shaders


# Standard shaders for WebGL rendering.

You don't need this module,
unless you want to write your own vertex or fragment shader
and a shader from here already provides one half.

Or if you're using WebGL directely.

## Vertex shaders
```elm
vertColoredRect : WebGL.Shader Game.TwoD.Shapes.Vertex { a | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } {}
```

The most basic shader, renders a rectangle.
Since it doesn't even pass along the texture coordinates,
it's only use is to create a colored rectangle.

---

```elm
vertTexturedRect : WebGL.Shader Game.TwoD.Shapes.Vertex { u | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }
```

A simple shader that passes the texture coordinates along for the fragment shader.
Can be generally used if the fragment shader needs to display texture(s).

---


## Fragment shaders
```elm
fragTextured : WebGL.Shader {} { u | texture : WebGL.Texture, tileWH : Math.Vector2.Vec2 } { vcoord : Math.Vector2.Vec2 }
```

Display a tiled texture.
TileWH specifys how many times the texture should be tiled.

---

```elm
fragAnimTextured : WebGL.Shader {} { u | texture : WebGL.Texture, bottomLeft : Math.Vector2.Vec2, topRight : Math.Vector2.Vec2, numberOfFrames : Int, duration : Float, time : Float } { vcoord : Math.Vector2.Vec2 }
```

A shader to render spritesheet animations.
It assumes that the animation frames are in one stripe

---

```elm
fragUniColor : WebGL.Shader {} { u | color : Math.Vector3.Vec3 } {}
```

A very simple shader, coloring the whole area in a single color

---



---

#Game.TwoD.Camera


This provides a basic camera.

```elm
type alias Camera = 
  { a | position : Math.Vector2.Vec2, width : Float }
```

A camera that always shows `width` units of the world.
It's an extensible record so that you could write your own camera

---


```elm
init : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera {}
```

Create a camera. You can also just use a record literal instead

---


---
used internally
```elm
getProjectionMatrix : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Math.Matrix4.Mat4
```

Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.

---



---

#Game.TwoD.Shapes


# Shapes for WebGL rendering.

You don't need this module,
unless you want to have a ready made qube for a custom vertex shader.
Since we're dealing with 2d only,
the only available shape is a qube

```elm
unitQube : WebGL.Drawable Game.TwoD.Shapes.Vertex
```

A qube with corners (0, 0), (1, 1)

---


```elm
type alias Vertex = 
  { a_position : Math.Vector2.Vec2 }
```

Just an alias for a 2d vector.
Needs to be in a record because it will be passed as an
attribute to the vertex shader

---



---

#Game.TwoD


A set of functions used to embed a 2d game into a webpage.
These functions specify the size and attributes passed to the canvas element.

You need to pass along the time, size and camera, as these are needed for rendering.

suggested import:

    import Game.TwoD as Game

```elm
type alias RenderConfig = 
  { time : Float , size : Game.Helpers.Int2 , camera : Game.TwoD.Camera.Camera a }
```

This is used by all the functions below, it represents all the shared state needed to render stuff.
If you don't use sprite animations you can use `0` for the time parameter.

---


## Canvas element only
```elm
render : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Creates a canvas element that renders the given renderables.

If you don't use animated sprites, you can use `0` for the time parameter.

    render { time = time, size = (800, 600), camera = state.camera }
        [ Background.render
        , Player.render state.Player
        ]

---

```elm
renderWithOptions : List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify additional attributes that will be passed to the canvas element.
A usefull trick to save some gpu processing at the cost of image quality is
to use a smaller `size` argument and than scale the canvas with css. e.g.

    renderWithOptions [style [("width", "800px"), ("height", "600px")]]
        { time = time, size = (400, 300), camera = camera }
        (World.render model.world)

---


## Embedded in a div
```elm
renderCentered : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Same as `render`, but wrapped in a div and nicely centered on the page using flexbox

---

```elm
renderCenteredWithOptions : List (Html.Attribute msg)
    -> List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify attributes for the container div and the canvas.

    renderCenteredWithOptions
        containerAttributes
        canvasAttributes
        renderConfig
        renderables

---



---

#Game.TwoD.Render


# 2D rendering module
This module provides a way to render commonly used objects in 2d games
like simple sprites and sprite animations.

It also provides colored recangels which can be great during prototyping.
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

```elm
type Renderable
    = Renderable
```

A representation of something that can be rendered.
To actually render a `Renderable` onto a webpage use the `Game.TwoD.*` functions

---


## Rectangles
```elm
rectangle : { o | color : Color.Color, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, great for prototyping

---

```elm
rectangleZ : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

The same, but with 3d position.

---

```elm
rectangleWithOptions : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, that can also be rotated

---


### With texture

Textures are `Maybe` values because you can never have a texture at the start of your game.
You first have to load your textures. In case you pass a `Nothing` as a value for a texture,
A gray rectangle will be displayed instead.

For loading textures I suggest keeping a dictionary of textures and then use your textures
by calling `Dict.get "textureId" model.textures` as this already returns a Maybe value
, making it a perfect fit to pass for the texture parameter.


```elm
sprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite.

---

```elm
spriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with 3d position

---

```elm
spriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, tiling : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with tiling and rotation.

    spriteWithOptions {config | tiling = (3,5)}

will create a sprite with a texture that reapeats itself 3 times horizontally and 5 times vertically.
TODO: picture!

---


### Animated
```elm
animatedSprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

An animated sprite. `bottomLeft` and `topRight` define a sub area from a texture
where the animation frames are located. It's a normalized coordinate from 0 to 1.

TODO: picture!

---

```elm
animatedSpriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

The same with 3d position

---

```elm
animatedSpriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

the same with rotation

---


## Custom
These are usefull if you want to write your own GLSL shaders.
When writing your own shaders, you might want to look at
Game.TwoD.Shaders and Game.TwoD.Shapes for reusable parts.


```elm
customFragment : Game.TwoD.Render.MakeUniformsFunc u
    -> { b | fragmentShader : WebGL.Shader {} { u | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }, pivot : Game.Helpers.Float2, position : Game.Helpers.Float3, rotation : Float, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

This allows you to write your own custom fragment shader.
The type signature may look terrifying,
but this is still easier than using veryCustom or using WebGL directely.
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

---

```elm
type alias MakeUniformsFunc = 
  { cameraProj : Math.Matrix4.Mat4 , time : Float , transform : Math.Matrix4.Mat4 } -> { a | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 }
```

Just an alias for this crazy function, needed when you want to use customFragment

---

```elm
veryCustom : ({ cameraProj : Math.Matrix4.Mat4, time : Float } -> WebGL.Renderable) -> Game.TwoD.Render.Renderable
```

This allows you to specify your own attributes, vertex shader and fragment shader by using the WebGL library directely.
If you use this you have to calculate your transformtions yourself.

If you need a quad as attributes, you can take the one from Game.TwoD.Shapes

TODO: Expose make transform

    veryCustom (\{cameraProj, time} ->
        WebGL.render vert frag Shapes.unitSquare
          { u_crazyFrog=frogTexture
          , transform=transform
          , camera=cameraProj
          }
    )

---

```elm
toWebGl : Float
    -> Math.Matrix4.Mat4
    -> Game.TwoD.Render.Renderable
    -> WebGL.Renderable
```

Converts a Renderable to a WebGL.Renderable.

    toWebGl time cameraProj renderable

---



---

#Game.TwoD.Shaders


# Standard shaders for WebGL rendering.

You don't need this module,
unless you want to write your own vertex or fragment shader
and a shader from here already provides one half.

Or if you're using WebGL directely.

## Vertex shaders
```elm
vertColoredRect : WebGL.Shader Game.TwoD.Shapes.Vertex { a | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } {}
```

The most basic shader, renders a rectangle.
Since it doesn't even pass along the texture coordinates,
it's only use is to create a colored rectangle.

---

```elm
vertTexturedRect : WebGL.Shader Game.TwoD.Shapes.Vertex { u | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }
```

A simple shader that passes the texture coordinates along for the fragment shader.
Can be generally used if the fragment shader needs to display texture(s).

---


## Fragment shaders
```elm
fragTextured : WebGL.Shader {} { u | texture : WebGL.Texture, tileWH : Math.Vector2.Vec2 } { vcoord : Math.Vector2.Vec2 }
```

Display a tiled texture.
TileWH specifys how many times the texture should be tiled.

---

```elm
fragAnimTextured : WebGL.Shader {} { u | texture : WebGL.Texture, bottomLeft : Math.Vector2.Vec2, topRight : Math.Vector2.Vec2, numberOfFrames : Int, duration : Float, time : Float } { vcoord : Math.Vector2.Vec2 }
```

A shader to render spritesheet animations.
It assumes that the animation frames are in one stripe

---

```elm
fragUniColor : WebGL.Shader {} { u | color : Math.Vector3.Vec3 } {}
```

A very simple shader, coloring the whole area in a single color

---



---

#Game.TwoD.Camera


This provides a basic camera.

You don't have to use this functions to get a working camera,
you can just fallow the `Camera` type.

E.g. in my game I have a camera that can follow the player and that does the right thing when the player dies etc.

```elm
type alias Camera = 
  { a | position : Math.Vector2.Vec2, width : Float }
```

A camera that always shows `width` units of the world.
It's an extensible record so that you can write your own camera

---


```elm
init : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera {}
```

Create a simple camera.

---


```elm
moveBy : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera by the given vector *relative* to the camera.

---


```elm
moveTo : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera to the given location. In *absolute* coordinates.

---


```elm
follow : Float
    -> Float
    -> ( Float, Float ) -> Game.TwoD.Camera.Camera a
    -> Game.TwoD.Camera.Camera a
```

Smoothely follow the given target. Use this in your tick function.

    follow 1.5 dt target camera

---



```elm
withZoom : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera { baseWidth : Float }
```

Create a camera with zooming capabilities. Serves as an example on how to create your own camera type

---


```elm
setZoom : Float -> Game.TwoD.Camera.Camera { baseWidth : Float } -> Game.TwoD.Camera.Camera { baseWidth : Float }
```



---


```elm
getZoom : Game.TwoD.Camera.Camera { baseWidth : Float } -> Float
```



---

---
## used internally

```elm
getProjectionMatrix : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Math.Matrix4.Mat4
```

Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.

---



---

#Game.TwoD.Shapes


# Shapes for WebGL rendering.

You don't need this module,
unless you want to have a ready made square for a custom vertex shader.
Since we're dealing with 2d only,
the only available shape is a square

```elm
unitSquare : WebGL.Drawable Game.TwoD.Shapes.Vertex
```

A square with corners (0, 0), (1, 1)

---


```elm
type alias Vertex = 
  { a_position : Math.Vector2.Vec2 }
```

Just an alias for a 2d vector.
Needs to be in a record because it will be passed as an
attribute to the vertex shader

---



---

# Game.TwoD


A set of functions used to embed a 2d game into a webpage.
These functions specify the size and attributes passed to the canvas element.

You need to pass along the time, size and camera, as these are needed for rendering.

suggested import:

    import Game.TwoD as Game

```elm
type alias RenderConfig = 
  { time : Float , size : Game.Helpers.Int2 , camera : Game.TwoD.Camera.Camera a }
```

This is used by all the functions below, it represents all the shared state needed to render stuff.
If you don't use sprite animations you can use `0` for the time parameter.

---


## Canvas element only
```elm
render : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Creates a canvas element that renders the given renderables.

If you don't use animated sprites, you can use `0` for the time parameter.

    render { time = time, size = (800, 600), camera = state.camera }
        [ Background.render
        , Player.render state.Player
        ]

---

```elm
renderWithOptions : List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify additional attributes that will be passed to the canvas element.
A usefull trick to save some gpu processing at the cost of image quality is
to use a smaller `size` argument and than scale the canvas with css. e.g.

    renderWithOptions [style [("width", "800px"), ("height", "600px")]]
        { time = time, size = (400, 300), camera = camera }
        (World.render model.world)

---


## Embedded in a div
```elm
renderCentered : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Same as `render`, but wrapped in a div and nicely centered on the page using flexbox

---

```elm
renderCenteredWithOptions : List (Html.Attribute msg)
    -> List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify attributes for the container div and the canvas.

    renderCenteredWithOptions
        containerAttributes
        canvasAttributes
        renderConfig
        renderables

---



---

# Game.TwoD.Render


# 2D rendering module
This module provides a way to render commonly used objects in 2d games
like simple sprites and sprite animations.

It also provides colored recangels which can be great during prototyping.
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

```elm
type Renderable
    = Renderable
```

A representation of something that can be rendered.
To actually render a `Renderable` onto a webpage use the `Game.TwoD.*` functions

---


## Rectangles
```elm
rectangle : { o | color : Color.Color, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, great for prototyping

---

```elm
rectangleZ : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

The same, but with 3d position.

---

```elm
rectangleWithOptions : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, that can also be rotated

---


### With texture

Textures are `Maybe` values because you can never have a texture at the start of your game.
You first have to load your textures. In case you pass a `Nothing` as a value for a texture,
A gray rectangle will be displayed instead.

For loading textures I suggest keeping a dictionary of textures and then use your textures
by calling `Dict.get "textureId" model.textures` as this already returns a Maybe value
, making it a perfect fit to pass for the texture parameter.


```elm
sprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite.

---

```elm
spriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with 3d position

---

```elm
spriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, tiling : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with tiling and rotation.

    spriteWithOptions {config | tiling = (3,5)}

will create a sprite with a texture that reapeats itself 3 times horizontally and 5 times vertically.
TODO: picture!

---


### Animated
```elm
animatedSprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

An animated sprite. `bottomLeft` and `topRight` define a sub area from a texture
where the animation frames are located. It's a normalized coordinate from 0 to 1.

TODO: picture!

---

```elm
animatedSpriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

The same with 3d position

---

```elm
animatedSpriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

the same with rotation

---


## Custom
These are usefull if you want to write your own GLSL shaders.
When writing your own shaders, you might want to look at
Game.TwoD.Shaders and Game.TwoD.Shapes for reusable parts.


```elm
customFragment : Game.TwoD.Render.MakeUniformsFunc u
    -> { b | fragmentShader : WebGL.Shader {} { u | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }, pivot : Game.Helpers.Float2, position : Game.Helpers.Float3, rotation : Float, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

This allows you to write your own custom fragment shader.
The type signature may look terrifying,
but this is still easier than using veryCustom or using WebGL directely.
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

---

```elm
type alias MakeUniformsFunc = 
  { cameraProj : Math.Matrix4.Mat4 , time : Float , transform : Math.Matrix4.Mat4 } -> { a | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 }
```

Just an alias for this crazy function, needed when you want to use customFragment

---

```elm
veryCustom : ({ cameraProj : Math.Matrix4.Mat4, time : Float } -> WebGL.Renderable) -> Game.TwoD.Render.Renderable
```

This allows you to specify your own attributes, vertex shader and fragment shader by using the WebGL library directely.
If you use this you have to calculate your transformtions yourself.

If you need a quad as attributes, you can take the one from Game.TwoD.Shapes

TODO: Expose make transform

    veryCustom (\{cameraProj, time} ->
        WebGL.render vert frag Shapes.unitSquare
          { u_crazyFrog=frogTexture
          , transform=transform
          , camera=cameraProj
          }
    )

---

```elm
toWebGl : Float
    -> Math.Matrix4.Mat4
    -> Game.TwoD.Render.Renderable
    -> WebGL.Renderable
```

Converts a Renderable to a WebGL.Renderable.

    toWebGl time cameraProj renderable

---



---

# Game.TwoD.Shaders


# Standard shaders for WebGL rendering.

You don't need this module,
unless you want to write your own vertex or fragment shader
and a shader from here already provides one half.

Or if you're using WebGL directely.

## Vertex shaders
```elm
vertColoredRect : WebGL.Shader Game.TwoD.Shapes.Vertex { a | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } {}
```

The most basic shader, renders a rectangle.
Since it doesn't even pass along the texture coordinates,
it's only use is to create a colored rectangle.

---

```elm
vertTexturedRect : WebGL.Shader Game.TwoD.Shapes.Vertex { u | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }
```

A simple shader that passes the texture coordinates along for the fragment shader.
Can be generally used if the fragment shader needs to display texture(s).

---


## Fragment shaders
```elm
fragTextured : WebGL.Shader {} { u | texture : WebGL.Texture, tileWH : Math.Vector2.Vec2 } { vcoord : Math.Vector2.Vec2 }
```

Display a tiled texture.
TileWH specifys how many times the texture should be tiled.

---

```elm
fragAnimTextured : WebGL.Shader {} { u | texture : WebGL.Texture, bottomLeft : Math.Vector2.Vec2, topRight : Math.Vector2.Vec2, numberOfFrames : Int, duration : Float, time : Float } { vcoord : Math.Vector2.Vec2 }
```

A shader to render spritesheet animations.
It assumes that the animation frames are in one stripe

---

```elm
fragUniColor : WebGL.Shader {} { u | color : Math.Vector3.Vec3 } {}
```

A very simple shader, coloring the whole area in a single color

---



---

# Game.TwoD.Camera


This provides a basic camera.

You don't have to use this functions to get a working camera,
you can just fallow the `Camera` type.

E.g. in my game I have a camera that can follow the player and that does the right thing when the player dies etc.

```elm
type alias Camera = 
  { a | position : Math.Vector2.Vec2, width : Float }
```

A camera that always shows `width` units of the world.
It's an extensible record so that you can write your own camera

---


```elm
init : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera {}
```

Create a simple camera.

---


```elm
moveBy : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera by the given vector *relative* to the camera.

---


```elm
moveTo : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera to the given location. In *absolute* coordinates.

---


```elm
follow : Float
    -> Float
    -> ( Float, Float ) -> Game.TwoD.Camera.Camera a
    -> Game.TwoD.Camera.Camera a
```

Smoothely follow the given target. Use this in your tick function.

    follow 1.5 dt target camera

---



```elm
withZoom : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera { baseWidth : Float }
```

Create a camera with zooming capabilities. Serves as an example on how to create your own camera type

---


```elm
setZoom : Float -> Game.TwoD.Camera.Camera { baseWidth : Float } -> Game.TwoD.Camera.Camera { baseWidth : Float }
```



---


```elm
getZoom : Game.TwoD.Camera.Camera { baseWidth : Float } -> Float
```



---

---
## used internally

```elm
getProjectionMatrix : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Math.Matrix4.Mat4
```

Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.

---



---

# Game.TwoD.Shapes


# Shapes for WebGL rendering.

You don't need this module,
unless you want to have a ready made square for a custom vertex shader.
Since we're dealing with 2d only,
the only available shape is a square

```elm
unitSquare : WebGL.Drawable Game.TwoD.Shapes.Vertex
```

A square with corners (0, 0), (1, 1)

---


```elm
type alias Vertex = 
  { a_position : Math.Vector2.Vec2 }
```

Just an alias for a 2d vector.
Needs to be in a record because it will be passed as an
attribute to the vertex shader

---



---

# Game.TwoD


A set of functions used to embed a 2d game into a webpage.
These functions specify the size and attributes passed to the canvas element.

You need to pass along the time, size and camera, as these are needed for rendering.

suggested import:

    import Game.TwoD as Game

```elm
type alias RenderConfig = 
  { time : Float , size : Game.Helpers.Int2 , camera : Game.TwoD.Camera.Camera a }
```

This is used by all the functions below, it represents all the shared state needed to render stuff.
If you don't use sprite animations you can use `0` for the time parameter.

---


## Canvas element only
```elm
render : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Creates a canvas element that renders the given renderables.

If you don't use animated sprites, you can use `0` for the time parameter.

    render { time = time, size = (800, 600), camera = state.camera }
        [ Background.render
        , Player.render state.Player
        ]

---

```elm
renderWithOptions : List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify additional attributes that will be passed to the canvas element.
A usefull trick to save some gpu processing at the cost of image quality is
to use a smaller `size` argument and than scale the canvas with css. e.g.

    renderWithOptions [style [("width", "800px"), ("height", "600px")]]
        { time = time, size = (400, 300), camera = camera }
        (World.render model.world)

---


## Embedded in a div
```elm
renderCentered : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Same as `render`, but wrapped in a div and nicely centered on the page using flexbox

---

```elm
renderCenteredWithOptions : List (Html.Attribute msg)
    -> List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify attributes for the container div and the canvas.

    renderCenteredWithOptions
        containerAttributes
        canvasAttributes
        renderConfig
        renderables

---



---

# Game.TwoD.Render


# 2D rendering module
This module provides a way to render commonly used objects in 2d games
like simple sprites and sprite animations.

It also provides colored recangels which can be great during prototyping.
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

```elm
type Renderable
    = Renderable
```

A representation of something that can be rendered.
To actually render a `Renderable` onto a webpage use the `Game.TwoD.*` functions

---


## Rectangles
```elm
rectangle : { o | color : Color.Color, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, great for prototyping

---

```elm
rectangleZ : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

The same, but with 3d position.

---

```elm
rectangleWithOptions : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, that can also be rotated

---


### With texture

Textures are `Maybe` values because you can never have a texture at the start of your game.
You first have to load your textures. In case you pass a `Nothing` as a value for a texture,
A gray rectangle will be displayed instead.

For loading textures I suggest keeping a dictionary of textures and then use your textures
by calling `Dict.get "textureId" model.textures` as this already returns a Maybe value
, making it a perfect fit to pass for the texture parameter.


```elm
sprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite.

---

```elm
spriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with 3d position

---

```elm
spriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, tiling : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with tiling and rotation.

    spriteWithOptions {config | tiling = (3,5)}

will create a sprite with a texture that reapeats itself 3 times horizontally and 5 times vertically.
TODO: picture!

---


### Animated
```elm
animatedSprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

An animated sprite. `bottomLeft` and `topRight` define a sub area from a texture
where the animation frames are located. It's a normalized coordinate from 0 to 1.

TODO: picture!

---

```elm
animatedSpriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

The same with 3d position

---

```elm
animatedSpriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

the same with rotation

---


## Custom
These are usefull if you want to write your own GLSL shaders.
When writing your own shaders, you might want to look at
Game.TwoD.Shaders and Game.TwoD.Shapes for reusable parts.


```elm
customFragment : Game.TwoD.Render.MakeUniformsFunc u
    -> { b | fragmentShader : WebGL.Shader {} { u | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }, pivot : Game.Helpers.Float2, position : Game.Helpers.Float3, rotation : Float, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

This allows you to write your own custom fragment shader.
The type signature may look terrifying,
but this is still easier than using veryCustom or using WebGL directely.
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

---

```elm
type alias MakeUniformsFunc = 
  { cameraProj : Math.Matrix4.Mat4 , time : Float , transform : Math.Matrix4.Mat4 } -> { a | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 }
```

Just an alias for this crazy function, needed when you want to use customFragment

---

```elm
veryCustom : ({ cameraProj : Math.Matrix4.Mat4, time : Float } -> WebGL.Renderable) -> Game.TwoD.Render.Renderable
```

This allows you to specify your own attributes, vertex shader and fragment shader by using the WebGL library directely.
If you use this you have to calculate your transformtions yourself.

If you need a quad as attributes, you can take the one from Game.TwoD.Shapes

TODO: Expose make transform

    veryCustom (\{cameraProj, time} ->
        WebGL.render vert frag Shapes.unitSquare
          { u_crazyFrog=frogTexture
          , transform=transform
          , camera=cameraProj
          }
    )

---

```elm
toWebGl : Float
    -> Math.Matrix4.Mat4
    -> Game.TwoD.Render.Renderable
    -> WebGL.Renderable
```

Converts a Renderable to a WebGL.Renderable.

    toWebGl time cameraProj renderable

---



---

# Game.TwoD.Shaders


# Standard shaders for WebGL rendering.

You don't need this module,
unless you want to write your own vertex or fragment shader
and a shader from here already provides one half.

Or if you're using WebGL directely.

## Vertex shaders
```elm
vertColoredRect : WebGL.Shader Game.TwoD.Shapes.Vertex { a | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } {}
```

The most basic shader, renders a rectangle.
Since it doesn't even pass along the texture coordinates,
it's only use is to create a colored rectangle.

---

```elm
vertTexturedRect : WebGL.Shader Game.TwoD.Shapes.Vertex { u | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }
```

A simple shader that passes the texture coordinates along for the fragment shader.
Can be generally used if the fragment shader needs to display texture(s).

---


## Fragment shaders
```elm
fragTextured : WebGL.Shader {} { u | texture : WebGL.Texture, tileWH : Math.Vector2.Vec2 } { vcoord : Math.Vector2.Vec2 }
```

Display a tiled texture.
TileWH specifys how many times the texture should be tiled.

---

```elm
fragAnimTextured : WebGL.Shader {} { u | texture : WebGL.Texture, bottomLeft : Math.Vector2.Vec2, topRight : Math.Vector2.Vec2, numberOfFrames : Int, duration : Float, time : Float } { vcoord : Math.Vector2.Vec2 }
```

A shader to render spritesheet animations.
It assumes that the animation frames are in one stripe

---

```elm
fragUniColor : WebGL.Shader {} { u | color : Math.Vector3.Vec3 } {}
```

A very simple shader, coloring the whole area in a single color

---



---

# Game.TwoD.Camera


This provides a basic camera.

You don't have to use this functions to get a working camera,
you can just fallow the `Camera` type.

E.g. in my game I have a camera that can follow the player and that does the right thing when the player dies etc.

```elm
type alias Camera = 
  { a | position : Math.Vector2.Vec2, width : Float }
```

A camera that always shows `width` units of the world.
It's an extensible record so that you can write your own camera

---


```elm
init : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera {}
```

Create a simple camera.

---


```elm
moveBy : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera by the given vector *relative* to the camera.

---


```elm
moveTo : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera to the given location. In *absolute* coordinates.

---


```elm
follow : Float
    -> Float
    -> ( Float, Float ) -> Game.TwoD.Camera.Camera a
    -> Game.TwoD.Camera.Camera a
```

Smoothely follow the given target. Use this in your tick function.

    follow 1.5 dt target camera

---



```elm
withZoom : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera { baseWidth : Float }
```

Create a camera with zooming capabilities. Serves as an example on how to create your own camera type

---


```elm
setZoom : Float -> Game.TwoD.Camera.Camera { baseWidth : Float } -> Game.TwoD.Camera.Camera { baseWidth : Float }
```



---


```elm
getZoom : Game.TwoD.Camera.Camera { baseWidth : Float } -> Float
```



---

---
## used internally

```elm
getProjectionMatrix : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Math.Matrix4.Mat4
```

Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.

---



---

# Game.TwoD.Shapes


# Shapes for WebGL rendering.

You don't need this module,
unless you want to have a ready made square for a custom vertex shader.
Since we're dealing with 2d only,
the only available shape is a square

```elm
unitSquare : WebGL.Drawable Game.TwoD.Shapes.Vertex
```

A square with corners (0, 0), (1, 1)

---


```elm
type alias Vertex = 
  { a_position : Math.Vector2.Vec2 }
```

Just an alias for a 2d vector.
Needs to be in a record because it will be passed as an
attribute to the vertex shader

---



---

# Game.TwoD


A set of functions used to embed a 2d game into a webpage.
These functions specify the size and attributes passed to the canvas element.

You need to pass along the time, size and camera, as these are needed for rendering.

suggested import:

    import Game.TwoD as Game

```elm
type alias RenderConfig = 
  { time : Float , size : Game.Helpers.Int2 , camera : Game.TwoD.Camera.Camera a }
```

This is used by all the functions below, it represents all the shared state needed to render stuff.
If you don't use sprite animations you can use `0` for the time parameter.

---


## Canvas element only
```elm
render : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Creates a canvas element that renders the given renderables.

If you don't use animated sprites, you can use `0` for the time parameter.

    render { time = time, size = (800, 600), camera = state.camera }
        [ Background.render
        , Player.render state.Player
        ]

---

```elm
renderWithOptions : List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify additional attributes that will be passed to the canvas element.
A usefull trick to save some gpu processing at the cost of image quality is
to use a smaller `size` argument and than scale the canvas with css. e.g.

    renderWithOptions [style [("width", "800px"), ("height", "600px")]]
        { time = time, size = (400, 300), camera = camera }
        (World.render model.world)

---


## Embedded in a div
```elm
renderCentered : Game.TwoD.RenderConfig a -> List Game.TwoD.Render.Renderable -> Html.Html x
```

Same as `render`, but wrapped in a div and nicely centered on the page using flexbox

---

```elm
renderCenteredWithOptions : List (Html.Attribute msg)
    -> List (Html.Attribute msg)
    -> Game.TwoD.RenderConfig a
    -> List Game.TwoD.Render.Renderable
    -> Html.Html msg
```

Same as above, but you can specify attributes for the container div and the canvas.

    renderCenteredWithOptions
        containerAttributes
        canvasAttributes
        renderConfig
        renderables

---



---

# Game.TwoD.Render


# 2D rendering module
This module provides a way to render commonly used objects in 2d games
like simple sprites and sprite animations.

It also provides colored recangels which can be great during prototyping.
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

```elm
type Renderable
    = Renderable
```

A representation of something that can be rendered.
To actually render a `Renderable` onto a webpage use the `Game.TwoD.*` functions

---


## Rectangles
```elm
rectangle : { o | color : Color.Color, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, great for prototyping

---

```elm
rectangleZ : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

The same, but with 3d position.

---

```elm
rectangleWithOptions : { o | color : Color.Color, position : Game.Helpers.Float3, size : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A colored rectangle, that can also be rotated

---


### With texture

Textures are `Maybe` values because you can never have a texture at the start of your game.
You first have to load your textures. In case you pass a `Nothing` as a value for a texture,
A gray rectangle will be displayed instead.

For loading textures I suggest keeping a dictionary of textures and then use your textures
by calling `Dict.get "textureId" model.textures` as this already returns a Maybe value
, making it a perfect fit to pass for the texture parameter.

**NOTE**: Texture dimensions have to be in a power of 2, e.g. 2^n x 2^m, like 4x16, 16x16, 512x256, etc.
If you try to use a non power of two texture, WebGL will spitt out a bunch of warnings and display a black rectangle.


```elm
sprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite.

---

```elm
spriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with 3d position

---

```elm
spriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, tiling : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

A sprite with tiling and rotation.

    spriteWithOptions {config | tiling = (3,5)}

will create a sprite with a texture that reapeats itself 3 times horizontally and 5 times vertically.
TODO: picture!

---


### Animated
```elm
animatedSprite : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float2, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

An animated sprite. `bottomLeft` and `topRight` define a sub area from a texture
where the animation frames are located. It's a normalized coordinate from 0 to 1.

TODO: picture!

---

```elm
animatedSpriteZ : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

The same with 3d position

---

```elm
animatedSpriteWithOptions : { o | texture : Maybe.Maybe WebGL.Texture, position : Game.Helpers.Float3, size : Game.Helpers.Float2, bottomLeft : Game.Helpers.Float2, topRight : Game.Helpers.Float2, rotation : Float, pivot : Game.Helpers.Float2, numberOfFrames : Int, duration : Float }
    -> Game.TwoD.Render.Renderable
```

the same with rotation

---


## Custom
These are usefull if you want to write your own GLSL shaders.
When writing your own shaders, you might want to look at
Game.TwoD.Shaders and Game.TwoD.Shapes for reusable parts.


```elm
customFragment : Game.TwoD.Render.MakeUniformsFunc u
    -> { b | fragmentShader : WebGL.Shader {} { u | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }, pivot : Game.Helpers.Float2, position : Game.Helpers.Float3, rotation : Float, size : Game.Helpers.Float2 }
    -> Game.TwoD.Render.Renderable
```

This allows you to write your own custom fragment shader.
The type signature may look terrifying,
but this is still easier than using veryCustom or using WebGL directely.
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

---

```elm
type alias MakeUniformsFunc = 
  { cameraProj : Math.Matrix4.Mat4 , time : Float , transform : Math.Matrix4.Mat4 } -> { a | cameraProj : Math.Matrix4.Mat4, transform : Math.Matrix4.Mat4 }
```

Just an alias for this crazy function, needed when you want to use customFragment

---

```elm
veryCustom : ({ cameraProj : Math.Matrix4.Mat4, time : Float } -> WebGL.Renderable) -> Game.TwoD.Render.Renderable
```

This allows you to specify your own attributes, vertex shader and fragment shader by using the WebGL library directely.
If you use this you have to calculate your transformtions yourself.

If you need a quad as attributes, you can take the one from Game.TwoD.Shapes

TODO: Expose make transform

    veryCustom (\{cameraProj, time} ->
        WebGL.render vert frag Shapes.unitSquare
          { u_crazyFrog=frogTexture
          , transform=transform
          , camera=cameraProj
          }
    )

---

```elm
toWebGl : Float
    -> Math.Matrix4.Mat4
    -> Game.TwoD.Render.Renderable
    -> WebGL.Renderable
```

Converts a Renderable to a WebGL.Renderable.

    toWebGl time cameraProj renderable

---



---

# Game.TwoD.Shaders


# Standard shaders for WebGL rendering.

You don't need this module,
unless you want to write your own vertex or fragment shader
and a shader from here already provides one half.

Or if you're using WebGL directely.

## Vertex shaders
```elm
vertColoredRect : WebGL.Shader Game.TwoD.Shapes.Vertex { a | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } {}
```

The most basic shader, renders a rectangle.
Since it doesn't even pass along the texture coordinates,
it's only use is to create a colored rectangle.

---

```elm
vertTexturedRect : WebGL.Shader Game.TwoD.Shapes.Vertex { u | transform : Math.Matrix4.Mat4, cameraProj : Math.Matrix4.Mat4 } { vcoord : Math.Vector2.Vec2 }
```

A simple shader that passes the texture coordinates along for the fragment shader.
Can be generally used if the fragment shader needs to display texture(s).

---


## Fragment shaders
```elm
fragTextured : WebGL.Shader {} { u | texture : WebGL.Texture, tileWH : Math.Vector2.Vec2 } { vcoord : Math.Vector2.Vec2 }
```

Display a tiled texture.
TileWH specifys how many times the texture should be tiled.

---

```elm
fragAnimTextured : WebGL.Shader {} { u | texture : WebGL.Texture, bottomLeft : Math.Vector2.Vec2, topRight : Math.Vector2.Vec2, numberOfFrames : Int, duration : Float, time : Float } { vcoord : Math.Vector2.Vec2 }
```

A shader to render spritesheet animations.
It assumes that the animation frames are in one horizontal line

---

```elm
fragUniColor : WebGL.Shader {} { u | color : Math.Vector3.Vec3 } {}
```

A very simple shader, coloring the whole area in a single color

---



---

# Game.TwoD.Camera


This provides a basic camera.

You don't have to use this functions to get a working camera,
you can just fallow the `Camera` type.

E.g. in my game I have a camera that can follow the player and that does the right thing when the player dies etc.

```elm
type alias Camera = 
  { a | position : Math.Vector2.Vec2, width : Float }
```

A camera that always shows `width` units of the world.
It's an extensible record so that you can write your own camera

---


```elm
init : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera {}
```

Create a simple camera.

---


```elm
moveBy : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera by the given vector *relative* to the camera.

---


```elm
moveTo : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Game.TwoD.Camera.Camera a
```

Move a camera to the given location. In *absolute* coordinates.

---


```elm
follow : Float
    -> Float
    -> ( Float, Float ) -> Game.TwoD.Camera.Camera a
    -> Game.TwoD.Camera.Camera a
```

Smoothely follow the given target. Use this in your tick function.

    follow 1.5 dt target camera

---



```elm
withZoom : ( Float, Float ) -> Float -> Game.TwoD.Camera.Camera { baseWidth : Float }
```

Create a camera with zooming capabilities. Serves as an example on how to create your own camera type

---


```elm
setZoom : Float -> Game.TwoD.Camera.Camera { baseWidth : Float } -> Game.TwoD.Camera.Camera { baseWidth : Float }
```



---


```elm
getZoom : Game.TwoD.Camera.Camera { baseWidth : Float } -> Float
```



---

---
## used internally

```elm
getProjectionMatrix : ( Float, Float ) -> Game.TwoD.Camera.Camera a -> Math.Matrix4.Mat4
```

Gets the transformation that represents how to transform the camera back to the origin.
The result of this is used in the vertex shader.

---



---

# Game.TwoD.Shapes


# Shapes for WebGL rendering.

You don't need this module,
unless you want to have a ready made square for a custom vertex shader.
Since we're dealing with 2d only,
the only available shape is a square

```elm
unitSquare : WebGL.Drawable Game.TwoD.Shapes.Vertex
```

A square with corners (0, 0), (1, 1)

---


```elm
type alias Vertex = 
  { a_position : Math.Vector2.Vec2 }
```

Just an alias for a 2d vector.
Needs to be in a record because it will be passed as an
attribute to the vertex shader

---



---

