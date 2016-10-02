# Elm render 2D game

This library aims to enable creating 2d games based on WebGL using elm.

TODO: pretty pictures and better examples

## Goals

My current goal is just to enable users with no WebGL and GLSL knowledge to create simple games.
Hopefully this will eventually grow into something bigger, but currently that's what this is.

This library is for you, if
 * you want to create a simple 2d game as a learning experience
 * you want to use elm
 * you've used elm-graphics, but are looking for a slightly more powerful option without going full WebGL.


If you want to create a "real" game, I strongly recommend other options such as Unity / Unreal3/4 / LibGdx etc...

## Vision

The vision for this library is to grow into something bigger.
Currently it only provides a way to render things to the screen.

It does not provide a way to structure your physics/gameplay code,
no resource management, no input management, no sound, no networking, etc.

However, the idea is that each of the mentioned missing topics can be created as a separate package that would live under the same namespace. E.g. a resource manager for textures (but eventually for sounds too) might live in a package called `elm-game-resources` and provide the namespace `Game.Resources`

## Examples
 * [Bouncy ball](https://zinggi.github.io/elm-2d-game-examples/bouncyBall.html) / [src](https://github.com/Zinggi/elm-2d-game-examples/bouncyBall.elm)

 * [Jump and run](https://zinggi.github.io/elm-2d-game-examples/MarioLike.html) / [src](https://github.com/Zinggi/elm-2d-game-examples/MarioLike.elm)

 * [Random tests](https://zinggi.github.io/elm-2d-game-examples/example1.html) / [src](https://github.com/Zinggi/elm-2d-game-examples/example1.elm)


## Docs
[Generated docs](documentation.md) (thanks to [@lorenzo](https://github.com/lorenzo)'s [tool](https://gist.github.com/lorenzo/090a770de6ba43df092181c4a421c5d5)) until this is published on [package.elm-lang.com](package.elm-lang.com)
