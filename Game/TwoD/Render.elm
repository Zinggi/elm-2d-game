module Game.TwoD.Render exposing (..)

import Color exposing (Color)
import WebGL exposing (Texture)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3)
import Game.TwoD.Shaders exposing (..)
import Game.TwoD.Shapes exposing (unitQube)
import Game.Helpers exposing (..)


type Renderable
    = ColoredRectangle { transform : Mat4, color : Vec3 }
    | TexturedRectangle { transform : Mat4, texture : Texture, tileWH : Vec2 }
    | AnimatedSprite { transform : Mat4, texture : Texture, bottomLeft : Vec2, topRight : Vec2, duration : Float, numberOfFrames : Int, time : Float }


toWebGl : Mat4 -> Renderable -> WebGL.Renderable
toWebGl cameraProj object =
    case object of
        ColoredRectangle { transform, color } ->
            WebGL.render vertColoredRect
                fragUniColor
                unitQube
                { transform = transform, color = color, cameraProj = cameraProj }

        TexturedRectangle { transform, texture, tileWH } ->
            WebGL.render vertTexturedRect
                fragTextured
                unitQube
                { transform = transform, texture = texture, cameraProj = cameraProj, tileWH = tileWH }

        AnimatedSprite { transform, texture, bottomLeft, topRight, duration, numberOfFrames, time } ->
            WebGL.render vertTexturedRect
                fragAnimTextured
                unitQube
                { transform = transform, texture = texture, cameraProj = cameraProj, bottomLeft = bottomLeft, topRight = topRight, duration = duration, time = (time - 1474052751360), numberOfFrames = numberOfFrames }


rectangle : { o | color : Color, position : Float2, size : Float2 } -> Renderable
rectangle { size, position, color } =
    let
        ( x, y ) =
            position
    in
        rectangleZ { size = size, position = ( x, y, 0 ), color = color }


rectangleZ : { o | color : Color, position : Float3, size : Float2 } -> Renderable
rectangleZ { color, position, size } =
    rectangleWithOptions
        { color = color, position = position, size = size, rotation = 0, pivot = ( 0, 0 ) }


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


texturedRectangle : { o | texture : Maybe Texture, position : Float2, size : Float2 } -> Renderable
texturedRectangle { texture, position, size } =
    let
        ( x, y ) =
            position
    in
        texturedRectangleZ { texture = texture, position = ( x, y, 0 ), size = size }


texturedRectangleZ : { o | texture : Maybe Texture, position : Float3, size : Float2 } -> Renderable
texturedRectangleZ { texture, position, size } =
    texturedRectangleWithOptions
        { texture = texture, position = position, size = size, tiling = ( 1, 1 ), rotation = 0, pivot = ( 0, 0 ) }


texturedRectangleWithOptions :
    { o | texture : Maybe Texture, position : Float3, size : Float2, tiling : Float2, rotation : Float, pivot : Float2 }
    -> Renderable
texturedRectangleWithOptions { texture, position, size, tiling, rotation, pivot } =
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
