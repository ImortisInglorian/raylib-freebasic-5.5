/'*********************************************************************************************
*
*   raylib.lights - Some useful functions to deal with lights data
*   FreeBASIC headers: Imortis Inglorian 2026
*   CONFIGURATION:
*
*   #define RLIGHTS_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers 
*       or source files without problems. But only ONE file should hold the implementation.
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2017-2024 Victor Fisac (@victorfisac) and Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
*********************************************************************************************'/

#define RLIGHTS_H

''----------------------------------------------------------------------------------
'' Defines and Macros
''----------------------------------------------------------------------------------
#define MAX_LIGHTS  4         '' Max dynamic lights supported by shader

''----------------------------------------------------------------------------------
'' Types and Structures Definition
''----------------------------------------------------------------------------------

'' Light data
type Light   
    as long lightType
    as long enabled
    as Vector3 position
    as Vector3 target
    as RLColor color
    as single attenuation
    
    '' Shader locations
    as long enabledLoc
    as long typeLoc
    as long positionLoc
    as long targetLoc
    as long colorLoc
    as long attenuationLoc
end type

'' Light type
type as long LightType
enum
    LIGHT_DIRECTIONAL = 0
    LIGHT_POINT
end enum


''----------------------------------------------------------------------------------
'' Module Functions Declaration
''----------------------------------------------------------------------------------
declare function CreateLight(lightType as long, position as Vector3, target as Vector3, clr as RLColor, shade as Shader) as Light   '' Create a light and get shader locations
declare sub UpdateLightValues(shade as Shader, lgt as Light)         '' Send light properties to shader



/'**********************************************************************************
*
*   RLIGHTS IMPLEMENTATION
*
***********************************************************************************'/

''----------------------------------------------------------------------------------
'' Global Variables Definition
''----------------------------------------------------------------------------------
dim shared as long lightsCount = 0    '' Current amount of created lights

''----------------------------------------------------------------------------------
'' Module Functions Definition
''----------------------------------------------------------------------------------

'' Create a light and get shader locations
function CreateLight(lightType as long, position as Vector3, target as Vector3, clr as RLColor, shade as Shader) as Light
    dim as Light lgt

    if lightsCount < MAX_LIGHTS then
        with lgt
            .enabled = 1
            .LightType = lightType
            .position = position
            .target = target
            .color = clr

            ' NOTE: Lighting shader naming must be the provided ones
            .enabledLoc = GetShaderLocation(shade, TextFormat("lights[%i].enabled", lightsCount))
            .typeLoc = GetShaderLocation(shade, TextFormat("lights[%i].type", lightsCount))
            .positionLoc = GetShaderLocation(shade, TextFormat("lights[%i].position", lightsCount))
            .targetLoc = GetShaderLocation(shade, TextFormat("lights[%i].target", lightsCount))
            .colorLoc = GetShaderLocation(shade, TextFormat("lights[%i].color", lightsCount))
        end with
        UpdateLightValues(shade, lgt)
        
        lightsCount+=1
    end if

    return lgt
end function

'' Send light properties to shader
'' NOTE: Light shader locations should be available 
sub UpdateLightValues(shade as Shader, lgt as Light)
    '' Send to shader light enabled state and type
    SetShaderValue(shade, lgt.enabledLoc, @lgt.enabled, SHADER_UNIFORM_INT)
    SetShaderValue(shade, lgt.typeLoc, @lgt.lightType, SHADER_UNIFORM_INT)

    '' Send to shader light position values
    dim as single position(0 to 2) = { lgt.position.x, lgt.position.y, lgt.position.z }
    SetShaderValue(shade, lgt.positionLoc, @position(0), SHADER_UNIFORM_VEC3)

    '' Send to shader light target position values
    dim as single target(0 to 2) = { lgt.target.x, lgt.target.y, lgt.target.z }
    SetShaderValue(shade, lgt.targetLoc, @target(0), SHADER_UNIFORM_VEC3)

    '' Send to shader light color values
    dim as single colors(0 to 3) = { lgt.color.r/255, lgt.color.g/255, _ 
                                     lgt.color.b/255, lgt.color.a/255 }
    SetShaderValue(shade, lgt.colorLoc, @colors(0), SHADER_UNIFORM_VEC4)
end sub
