module Engine.Material.MaterialValues exposing (MaterialProperty, MaterialValues)

import Math.Vector3 exposing (Vec3, vec3)
{-| Represent a property of a material. Contains a color and a strength.
By convention, full strength is set at 1 an no strength is 0,
color values are between 0 and 1 (not 0 - 255).

Example (creating a white specular property at full strength):

    specularProperty = MaterialProperty (vec3 1 1 1) 1

From the above, the specularProperty variable is given a white color and
full strength. If this property is used to represent specular highlights,
then this means that these highlights will appear white and very visible.

-}
type alias MaterialProperty = {
  color : Vec3,
  strength : Float
}

type alias MaterialValues = {
  emissive : MaterialProperty,
  ambient  : MaterialProperty,
  diffuse  : MaterialProperty,
  specular : MaterialProperty
}