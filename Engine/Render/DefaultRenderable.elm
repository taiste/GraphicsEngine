module Engine.Render.DefaultRenderable exposing (renderable)

{-| This module contains the definition for the default Renderable renderable.
This definition is separated from the Renderable module in order to avoid
circular dependencies.


# Default Renderable
@docs renderable
-}

import Engine.Render.Renderable exposing (Renderable)
import Engine.Material.MaterialValues exposing (MaterialValues)
import Engine.Mesh.Cube exposing (cube)
import Engine.Shader.Attribute exposing (Attribute)
import Engine.Shader.Varying exposing (Varying)
import Engine.Shader.Uniform exposing (Uniform)

{-| Default renderable object. Alias for the default cube object.
-}
renderable : Renderable MaterialValues Attribute Uniform Varying 
renderable = cube
