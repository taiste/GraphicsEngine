module Engine.Render.Render exposing (renderObject, render, renderWith)

{-| This module contains functions to render objects and scenes onto
a WebGL canvas context.

# Render Functions
@docs renderObject, render, renderWith

-}

import WebGL exposing (Entity, Option, entity, toHtml, toHtmlWith)
import Html exposing (..)

import Engine.Render.Renderable exposing (Renderable)
import Engine.Scene.Scene exposing (Scene)
import Engine.Shader.Uniform exposing (constructUniform)
import Engine.Shader.Shader exposing (constructVertexShader, constructFragmentShader)

import Array exposing (map, toList)

{-| Function to render an object onto a scene. This function returns an
Entity object which is what the webgl function from the WebGL library requires
to draw anything onto a WebGL canvas context.

Note: This function is mainly used as a helper function to render.
-}
renderObject : Scene -> Renderable -> Entity
renderObject scene object =
  entity (constructVertexShader   object.material.vertexShader)
         (constructFragmentShader object.material.fragmentShader)
         object.mesh
         (constructUniform scene object)


{-| Function to render a scene to a WebGL canvas context. This function takes
in a Scene and returns the WebGL canvas context.

Note: The function renders only the objects in the objects list of the scene.
-}
render : Scene -> List (Html.Attribute msg) -> Html msg
render scene attributes = Array.map (renderObject scene) scene.objects 
  |> toList
  |> toHtml attributes


{-| Function to render a scene to a WebGL canvas context. This function takes
in a Scene and returns the WebGL canvas context.

Note: The function renders only the objects in the objects list of the scene.
-}
renderWith : List Option -> Scene -> List (Html.Attribute msg) -> Html msg
renderWith options scene attributes = Array.map (renderObject scene) scene.objects 
  |> toList
  |> toHtmlWith options attributes
