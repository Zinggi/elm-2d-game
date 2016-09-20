module Helpers exposing (..)

import Task
import WebGL exposing (Texture)


loadTextures : (String -> msg) -> (String -> Texture -> msg) -> List String -> Cmd msg
loadTextures failed success urls =
    urls
        |> List.map
            (\url ->
                Task.perform (\_ -> failed url)
                    (success url)
                    (WebGL.loadTexture url)
            )
        |> Cmd.batch
