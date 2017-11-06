module Engine.Math.Utils exposing
  ( safeNormalize, safeMakeRotate
  , getSideVector, getUpVector, getForwardVector, getTargetPosition
  , modelMatrix, viewMatrix, projectionMatrix
  , matrixIdentity, modelViewMatrix, modelViewProjectionMatrix, normalMatrix, makeRotation, hamiltonProduct
  )

{-| This module is just a simple collection of mathematical operations
used repeatedly in several areas in the Graphics Engine codebase.

# "Safe" versions of Linear Algbera operations
@docs safeNormalize, safeMakeRotate

# Common Camera operations
@docs getSideVector, getUpVector, getForwardVector, getTargetPosition, makeRotation, hamiltonProduct

# Model View Projection
@docs modelMatrix, viewMatrix, projectionMatrix

# Renaming Functions to avoid Namespace clashes
@docs matrixIdentity, modelViewMatrix, modelViewProjectionMatrix, normalMatrix

-}

import Math.Vector3 as Vector3 exposing (..)
import Math.Vector4 as Vector4 exposing (..)
import Math.Matrix4 as Matrix4 exposing (..)
import Engine.Transform.Transform exposing (Transform)
import Engine.Camera.Camera exposing (Camera)

-- Generic Math functions

{-| Version of Vector3.normalize which simply returns the vector to be
normalized untouched in the case its length is equal to zero

In essence,

    safeNormalize (vec3 0 0 0) == vec3 0 0 0

-}
safeNormalize : Vector3.Vec3 -> Vector3.Vec3
safeNormalize vector =
  if (Vector3.lengthSquared vector == 0)
  then vector
  else Vector3.normalize vector

{-| Version of Matrix4.makeRotate which simply returns the identity
matrix if the input rotation vector is the zero vector

In essence,

    safeMakeRotate (vec3 0 0 0) == Matrix4.identity

-}
safeMakeRotate : Vector4.Vec4 -> Matrix4.Mat4
safeMakeRotate vector =    
    let imag1 = Vector4.getX vector
        imag2 = Vector4.getY vector
        imag3 = Vector4.getZ vector
        imagLength = sqrt (imag1 * imag1 + imag2 * imag2 + imag3 * imag3)
        rotAxis = Vector3.vec3 (imag1 / imagLength) (imag2 / imagLength) (imag3 / imagLength)
        angle = 2 * atan2 imagLength (Vector4.getW vector)
    in if imagLength < 0.000001 then matrixIdentity else makeRotate angle rotAxis
 
{-| Renaming of the identity matrix because it clashes with the identity
function in Basics which defines the function that just returns its input

-}
matrixIdentity : Matrix4.Mat4
matrixIdentity = Matrix4.identity

-- Camera Helpers

{-| Calculate the right-handed side vector of a transform. This is mainly
used by cameras to help orient themselves.

-}
getSideVector : Transform a -> Vector3.Vec3
getSideVector transform =
  let rotation = safeMakeRotate transform.rotation 
  in Matrix4.transform rotation Vector3.i


{-| Calculate the right-handed up vector of a transform. This is mainly
used by cameras to help orient themselves and create the view matrix.

-}
getUpVector : Transform a -> Vector3.Vec3
getUpVector transform =
  let rotation = safeMakeRotate transform.rotation 
  in Matrix4.transform rotation Vector3.j

{-| Calculate the vector pointing outward of a transform given a position
and rotation. This is mainly used by cameras to help orient themselves
and create the view matrix.

-}
getForwardVector : Transform a -> Vector3.Vec3
getForwardVector transform =
  let rotation = safeMakeRotate transform.rotation 
  in Matrix4.transform rotation Vector3.k

{-| Calculate the target position of a transform (i.e. where the transform
points at). This is mainly used to figure out what a camera points at.

-}
getTargetPosition : Transform a -> Vector3.Vec3
getTargetPosition transform =
  Vector3.add transform.position (getForwardVector transform)



-- Model View Projection Matrices

{-| The model matrix. Encodes the transformation of a transform as a matrix.
This allows to efficiently apply such a transformation to a point to move it
in world space with a given position, rotation, and scale.
-}
modelMatrix : Transform a -> Matrix4.Mat4
modelMatrix transform =
  let translationMatrix = Matrix4.makeTranslate transform.position
      rotationMatrix    = safeMakeRotate transform.rotation
      scaleMatrix       = Matrix4.makeScale transform.scale
  in Matrix4.mul translationMatrix (Matrix4.mul rotationMatrix scaleMatrix)

{-| The view matrix. Encodes the Look At matrix of a transform.
This allows to calculate the Look At matrix of a camera to then multiply
a position by the view matrix in order to convert it from world space to
camera space.
-}
viewMatrix : Transform a -> Matrix4.Mat4
viewMatrix transform =
  Matrix4.makeLookAt transform.position
                     (getTargetPosition transform)
                     (getUpVector transform)

{-| The projection matrix. Encodes the perspective matrix of a camera.
This allows to map a position from camera space to screen space.
-}
projectionMatrix : Camera -> Matrix4.Mat4
projectionMatrix camera =
  Matrix4.makePerspective camera.fieldOfView
                          camera.aspectRatio
                          camera.nearClipping
                          camera.farClipping

{-| Shorthand for modelViewMatrix. Faster to calculate once in CPU.
-}
modelViewMatrix : Transform a -> Transform b -> Matrix4.Mat4
modelViewMatrix object camera =
  Matrix4.mul (viewMatrix camera) (modelMatrix object)

{-| Shorthand for modelViewProjectionMatrix. Faster to calculate once in CPU.
-}
modelViewProjectionMatrix : Transform a -> Camera -> Matrix4.Mat4
modelViewProjectionMatrix object camera =
  Matrix4.mul (projectionMatrix camera) (modelViewMatrix object camera)

{-| Shorthand for normalMatrix. Faster to calculate once in CPU.
-}
normalMatrix : Transform a -> Transform b -> Matrix4.Mat4
normalMatrix object camera =
  Matrix4.inverseOrthonormal (Matrix4.transpose (modelViewMatrix object camera))

{-| Make rotation quaternion from rotation axis and angle
-}
makeRotation : Vec3 -> Float -> Vec4
makeRotation axis angle = 
    let cosAngle = cos (angle / 2)
        sinAngle = sin (angle / 2)
        xComp = (Vector3.getX axis) * -sinAngle
        yComp = (Vector3.getY axis) * -sinAngle
        zComp = (Vector3.getZ axis) * -sinAngle
    in Vector4.vec4 xComp yComp zComp cosAngle

{-| Hamilton product aka quaternion product -}
hamiltonProduct : Vec4 -> Vec4 -> Vec4
hamiltonProduct first second = 
    let x1 = Vector4.getX first
        y1 = Vector4.getY first
        z1 = Vector4.getZ first
        r1 = Vector4.getW first
        x2 = Vector4.getX second
        y2 = Vector4.getY second
        z2 = Vector4.getZ second
        r2 = Vector4.getW second
        newX = r1 * x2 + x1 * r2 + y1 * z2 - z1 * y2
        newY = r1 * y2 + y1 * r2 + z1 * x2 - x1 * z2
        newZ = r1 * z2 + z1 * r2 + x1 * y2 - y1 * x2
        newR = r1 * r2 - x1 * x2 - y1 * y2 - z1 * z2
    in Vector4.vec4 newX newY newZ newR

