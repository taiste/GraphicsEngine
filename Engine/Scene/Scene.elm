module Engine.Scene.Scene exposing (Scene, scene, constructUniforms)

{-| This module defines the Scene type and the default Scene object.
A Scene contains a camera (the viewer's window to the scene), a list of
Renderable objects (the stuff that gets drawn to the scene), a light
(something to illuminate the scene), and a Viewport (a description of
the context the scene gets drawn to).

Note: Currently, Graphics Engine only supports having one light. In future
releases, this will most certainly change in order to support having multiple
lights in a scene.

Note: Currently, Graphics Engine onlu supports having one camera. While this
may be all you need in most cases, it may be valuable to allow for multiple
cameras. Currently, the only way to have multiple cameras is to have
multiple scenes. It is still an open question on which approach is better.


# Definition
@docs Scene

# Default Scene
@docs scene
-}

import Engine.Camera.Camera exposing (Camera, camera)
import Engine.Render.Renderable exposing (Renderable)
import Engine.Light.Light exposing (Light, light)
import Engine.Render.DefaultRenderable exposing (renderable)
import Engine.Viewport.Viewport exposing (Viewport, viewport)
import Engine.Material.MaterialValues exposing (MaterialProperty, MaterialValues)
import Engine.Shader.Attribute exposing (Attribute)
import Engine.Shader.Varying exposing (Varying)
import Engine.Shader.Uniform exposing (Uniform)
import Engine.Math.Utils exposing (
  modelMatrix,
  viewMatrix,
  projectionMatrix,
  modelViewMatrix,
  modelViewProjectionMatrix,
  normalMatrix)

import Array exposing (Array, fromList)

-- TODO: Find a strategy to deal with multiple lights

-- TODO: Consider a strategy for dealing with multiple cameras
--       -- Perhaps by using multiple webgl contexts??

-- TODO: Find a strategy to deal with multiple materials

{-| Represents a scene. A scene contains an array of objects such that
calling `render` on a scene will render all the objects in a webgl context.

A scene contains a camera to define the viewer's viewing point, a light to
illuminate the scene, and a viewport to describe the context on which the
scene will be drawn.

-}
type alias Scene d a u v = {
  camera    : Camera,
  objects   : Array (Renderable d a u v),
  light     : Light,
  viewport  : Viewport
}

{-| Default scene object. Draws a red cube in the middle of the default context.
-}
scene : Scene MaterialValues Attribute Uniform Varying 
scene = {
  camera   = camera,
  objects  = fromList [renderable],
  light    = light,
  viewport = viewport }

constructUniforms : Scene MaterialValues a Uniform v -> Renderable MaterialValues a Uniform v -> Uniform
constructUniforms scene object = {
  light = scene.light,
  viewMatrix = viewMatrix scene.camera,
  modelViewProjectionMatrix = modelViewProjectionMatrix object scene.camera,
  modelViewMatrix = modelViewMatrix object scene.camera,
  material = object.material.values,
  normalMatrix = normalMatrix object scene.camera }