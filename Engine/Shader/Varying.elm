module Engine.Shader.Varying exposing (Varying)

import Math.Vector3 exposing (Vec3)

type alias Varying = { 
  vPosition : Vec3, 
  vNormal : Vec3, 
  vViewPosition : Vec3 
}
