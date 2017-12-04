module Engine.Material.Material exposing (Material, material)

{-| This module defined the Material type and the default material object.
A Material is a record type made to define how an object reacts to light
in a scene and draws itself.

# Definition
@docs Material

# Default Material
@docs material

# Convenient Helper Type
@docs MaterialProperty

-}

import Math.Vector3 exposing (Vec3, vec3)
import Engine.Shader.VertexShader exposing (vertexShader)
import Engine.Shader.FragmentShader exposing (fragmentShader)
import Engine.Material.MaterialValues exposing (MaterialProperty, MaterialValues)


{-| Represent a material. A Material has properties to help it define
and adapt how it reacts to light.

Emissive usually models light that seems to emanate from the object itself.

Ambient usually represents some ambient term so that objects may be somewhat
visible in the dark. (to compensate for not using a ray tracer)

Diffuse usually models the scatter of light on a surface. Rough objects
tend to have a high diffuse strength as the light's reflection does not
seem to focus on a small area but rather "diffuses" or spreads on the entire
surface.

Specular usually models specular highlights, or shinyness. Metallic objects
tend to have a high specular strength as they seem to almost act as a
mirror and a light's reflection seems to focus on a small area.

Note: Diffuse and Specular are completely independent, they seem
to be opposites but you can perfectly have a material with both high diffuse
and specular strengths and you can also perfectly have a material with both
low diffuse and specular strengths.

A Material also has a vertex shader and a fragment shader. A Shader is a
program that is sent to the GPU (Graphics Processing Unit).

The vertex shader controls where a point is displayed on the screen. Usually,
it suffices to just have a vertex shader that converts a position from world
coordinates to screen coodinates.

The fragment shader controls what color a given fragment (just think pixel) has.
Fragment shaders can often get very involved as they often calculate
the contributions due to all the light sources in a scene and somehow mix
this with the position, normal, and material properties of an object to
finally get a pixel color.

Note: Both the vertex and fragment shaders are written in the GLSL
programming language. To use your own shaders simply make sure to pass them
to a material as a String.
-}
type alias WithShaders c a b = { c |
  vertexShader    : VertexShader a b,
  fragmentShader  : FragmentShader b
}

type alias Material a b = WithShaders MaterialValues a b

{-| Default material. Defines a material with a weak white ambient and no
emissive, diffuse, or specular terms. (i.e. a simple flat material)

The current default shaders are a standard vertex shader that converts from
world to screen coordinates and a fragment shader that just returns a red pixel.

This is ideal for creating your own materials and to just use a simple
default material.
-}
material : Material a b 
material = {
  emissive = MaterialProperty (vec3 0 0 0) 0,
  ambient  = MaterialProperty (vec3 1 1 1) 0.2,
  diffuse  = MaterialProperty (vec3 0 0 0) 0,
  specular = MaterialProperty (vec3 0 0 0) 0,
  vertexShader = vertexShader,
  fragmentShader = fragmentShader }
