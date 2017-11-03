module Engine.Render.Renderable exposing (Renderable, RenderablePart, simpleRenderable)

{-| This module contains the definition of the Renderable type. This is
separated from the definition of the default renderable object in order to
avoid circular dependencies.

# Definition
@docs Renderable

-}

import WebGL exposing (Mesh)

import Math.Vector3 exposing (vec3)
import Engine.Transform.Transform exposing (Transform)
import Engine.Material.Material exposing (Material)
import Array exposing (Array, fromList)

{-| Represent a renderable object. A renderable object is an Object with a
Transform properties (position, rotation, and scale) in order to locate it
physically in world space. A renderable object also comes with a Material
and a Mesh.

A renderable uses its position, rotation, and scale to set its position,
rotation and scale in world space respectively. The material describes how
the renderable object responds to light and draws itself. The mesh describes
the geometry of the renderable object (if it is a cube, a pyramid, etc...).

-}
type alias RenderablePart d a u v = {  
  material : Material d a u v,
  mesh     : Mesh a
}

type alias Renderable d a u v = Transform {
  parts : Array (RenderablePart d a u v)
}

simpleRenderable : Mesh a -> Material d a u v -> Renderable d a u v
simpleRenderable mesh material = 
    { parts = fromList [RenderablePart material mesh]
    , position = vec3 0 0 0
    , rotation = vec3 0 0 0
    , scale    = vec3 1 1 1
    }