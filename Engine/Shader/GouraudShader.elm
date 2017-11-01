module Engine.Shader.GouraudShader exposing (gouraudShader, GouraudShader)

import WebGL exposing (Shader)
import Math.Vector3 exposing (Vec3)
import Math.Matrix4 exposing (Mat4)
import Engine.Material.MaterialValues exposing (MaterialValues)
import Engine.Light.Light exposing (Light)
import Engine.Shader.Varying exposing (Varying)

type alias GouraudShader u = Shader
        {}
        { u
            | light : Light
            , material : MaterialValues
            , viewMatrix : Mat4
        }
        Varying


gouraudShader : GouraudShader u
gouraudShader = [glsl|
precision mediump float;

struct MaterialProperty {
  vec3 color;
  float strength;
};

struct Material {
  MaterialProperty emissive;
  MaterialProperty ambient;
  MaterialProperty diffuse;
  MaterialProperty specular;
};

struct Light {
  vec3 position;
  vec3 rotation;
  vec3 color;
  float intensity;
};

uniform Light light;
uniform Material material;
uniform mat4 viewMatrix;

varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vViewPosition;

void main(){
  vec3 normal = normalize(vNormal);
  vec3 viewVector = normalize(vViewPosition);
  vec4 lightDirection = viewMatrix * vec4(light.position, 1.0);
  vec3 lightVector = normalize(lightDirection.xyz);
  vec3 pointHalfVector = normalize(lightVector + viewVector);
  float pointDotHalfNormal = max(dot(normal, pointHalfVector), 0.0);


  vec3 lightContribution = light.color * max(min(light.intensity, 1.0), 0.5);

  vec3 emissiveContribution = material.emissive.color * material.emissive.strength;
  vec3 ambientContribution = material.ambient.color * material.ambient.strength;

  float diffuseFactor = max( dot(normal, lightVector), 0.0) / 2.0;
  vec3 diffuseContribution = material.diffuse.color * material.diffuse.strength * diffuseFactor;
  vec3 outputColor = vec3(0.0,0.0,0.0);

  outputColor += 0.25 * ambientContribution;

  outputColor += 0.25 * emissiveContribution;

  outputColor += 0.25 * diffuseContribution;

  float shininess = material.specular.strength * 100.0;
  float specularFactor = material.specular.strength * pow( pointDotHalfNormal, shininess);
  specularFactor *= diffuseFactor * (2.0  +  shininess) / 8.0;

  if (diffuseFactor <= 0.0){
    specularFactor = 0.0;
  }

  vec3 specularContribution = material.specular.color * specularFactor;

  outputColor += 0.25 * specularContribution;

  gl_FragColor = vec4(outputColor, 1.0);
}

|] 
