module Engine.Render.Render exposing (renderObject, render, renderWith, UniformMaker)

{-| This module contains functions to render objects and scenes onto
a WebGL canvas context.

# Render Functions
@docs renderObject, render, renderWith

-}

import WebGL exposing (Entity, Option, Shader, entity, toHtml, toHtmlWith)
import Html exposing (..)

import Engine.Render.Renderable exposing (Renderable)
import Engine.Scene.Scene exposing (Scene)

import Array exposing (map, toList)

type alias UniformMaker d a u v = Scene d a u v -> Renderable d a u v -> u
{-| Function to render an object onto a scene. This function returns an
Entity object which is what the webgl function from the WebGL library requires
to draw anything onto a WebGL canvas context.

Note: This function is mainly used as a helper function to render.
-}
renderObject : UniformMaker d a u v -> Scene d a u v -> Renderable d a u v -> Entity
renderObject constructUniforms scene object =
  entity object.material.vertexShader
         object.material.fragmentShader
         object.mesh
         (constructUniforms scene object)

{-| Function to render a scene to a WebGL canvas context. This function takes
in a Scene and returns the WebGL canvas context.

Note: The function renders only the objects in the objects list of the scene.
-}
render : UniformMaker d a u v -> Scene d a u v -> List (Html.Attribute msg) -> Html msg
render constructUniforms scene attributes = Array.map (renderObject constructUniforms scene) scene.objects 
  |> toList
  |> toHtml attributes

{-| Function to render a scene to a WebGL canvas context. This function takes
in a Scene and returns the WebGL canvas context.

Note: The function renders only the objects in the objects list of the scene.
-}
renderWith : List Option -> UniformMaker d a u v -> Scene d a u v -> List (Html.Attribute msg) -> Html msg
renderWith options constructUniforms scene attributes = Array.map (renderObject constructUniforms scene) scene.objects 
  |> toList
  |> toHtmlWith options attributes
