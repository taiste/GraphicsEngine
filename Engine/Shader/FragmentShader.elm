module Engine.Shader.FragmentShader exposing (fragmentShader, FragmentShader)

{-| This module contains the definition of the default fragment shader.

# Default Fragment Shader
@docs fragmentShader

-}
import WebGL exposing (Shader)
import Math.Vector3 exposing (Vec3)
import Engine.Material.MaterialValues exposing (MaterialValues)
import Engine.Light.Light exposing (Light)
import Math.Matrix4 exposing (Mat4)
import Engine.Shader.Varying exposing (Varying)

type alias FragmentShader u = Shader {} u Varying

{-| Default fragment shader

Currently, the fragment shader just sets the fragment color to red.

-}
fragmentShader : FragmentShader u
fragmentShader = [glsl|
precision mediump float;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vViewPosition;

void main(){
  vec3 outputColor = normalize(vPosition) * sqrt(3.0);
  gl_FragColor = vec4(outputColor,1.0);
}

|]