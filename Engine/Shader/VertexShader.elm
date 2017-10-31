module Engine.Shader.VertexShader exposing (vertexShader)

{-| This module contains the definition of the default vertex shader.

# Default Vertex Shader
@docs vertexShader

-}

import WebGL exposing (Shader)
import Math.Vector3 exposing (Vec3)
import Math.Matrix4 exposing (Mat4)




{-| Default Vertex Shader.

Currently, the vertex shader just applied the model view projection
transformation onto the vertex position and passes the new position
as a varying to the fragment shader.

-}
vertexShader : Shader 
        { a | position : Vec3 } 
        { b | modelViewMatrix : Mat4, modelViewProjectionMatrix : Mat4, normalMatrix : Mat4 }
        { vNormal : Vec3, vPosition : Vec3, vViewPosition : Vec3 }
vertexShader = 
    [glsl|
precision mediump float;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vViewPosition;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 normalMatrix;

attribute vec3 position;

void main (){
  vec4 outputPosition = modelViewProjectionMatrix * vec4(position, 1.0);
  vec4 modelViewPosition = modelViewMatrix * vec4(position, 1.0);
  gl_Position = outputPosition;
  vPosition = outputPosition.xyz;
  vNormal = normalize(mat3(normalMatrix) * position);
  vViewPosition = -modelViewPosition.xyz;
}

|]