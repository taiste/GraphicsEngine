module Engine.Shader.Uniform exposing (Uniform)

{-| This module contains the definition of the Uniform type and
a function to construct a uniform from a scene and a renderable object

# Definition
@docs Uniform

# Construct a Uniform
@docs constructUniform

-}

import Math.Vector3 exposing (Vec3)
import Math.Matrix4 exposing (Mat4)
import Engine.Render.Renderable exposing (Renderable)
import Engine.Scene.Scene exposing (Scene)


type alias Uniform = {
  light : Light,
  viewMatrix : Mat4,
  modelViewProjectionMatrix : Mat4,
  modelViewMatrix : Mat4,
  material : MaterialValues,
  normalMatrix : Mat4
}
