module Engine.Render.Render exposing (renderObject, render, renderWith, UniformMaker)

{-| This module contains functions to render objects and scenes onto
a WebGL canvas context.

# Render Functions
@docs renderObject, render, renderWith

-}

import WebGL exposing (Entity, Option, Shader, entity, toHtml, toHtmlWith)
import Html exposing (..)

import Engine.Transform.Transform exposing (Transform)
import Engine.Render.Renderable exposing (Renderable, RenderablePart)
import Engine.Scene.Scene exposing (Scene)

import Array exposing (map, toList)

type alias UniformMaker d a u v = Scene d a u v -> Renderable d a u v -> d -> u
{-| Function to render an object onto a scene. This function returns an
Entity object which is what the webgl function from the WebGL library requires
to draw anything onto a WebGL canvas context.

Note: This function is mainly used as a helper function to render.
-}
renderObject : UniformMaker d a u v -> Scene d a u v -> Renderable d a u v -> List Entity
renderObject constructUniforms scene object = 
    let renderPart = renderObjectPart constructUniforms scene object
    in List.map renderPart <| Array.toList object.parts

renderObjectPart : UniformMaker d a u v -> Scene d a u v -> Renderable d a u v -> RenderablePart d a u v -> Entity
renderObjectPart constructUniforms scene transform part =
  entity part.material.vertexShader
         part.material.fragmentShader
         part.mesh
         (constructUniforms scene transform part.material.values)


{-| Function to render a scene to a WebGL canvas context. This function takes
in a Scene and returns the WebGL canvas context.

Note: The function renders only the objects in the objects list of the scene.
-}
render : UniformMaker d a u v -> Scene d a u v -> List (Html.Attribute msg) -> Html msg
render constructUniforms scene attributes = Array.map (renderObject constructUniforms scene) scene.objects 
  |> toList
  |> List.concat
  |> toHtml attributes

{-| Function to render a scene to a WebGL canvas context. This function takes
in a Scene and returns the WebGL canvas context.

Note: The function renders only the objects in the objects list of the scene.
-}
renderWith : List Option -> UniformMaker d a u v -> Scene d a u v -> List (Html.Attribute msg) -> Html msg
renderWith options constructUniforms scene attributes = Array.map (renderObject constructUniforms scene) scene.objects 
  |> toList
  |> List.concat
  |> toHtmlWith options attributes
