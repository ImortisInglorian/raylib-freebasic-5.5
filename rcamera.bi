/'******************************************************************************************
*
*   rcamera - Basic camera system with support for multiple camera modes
*
*   CONFIGURATION:
*       #define RCAMERA_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RCAMERA_STANDALONE
*           If defined, the library can be used as standalone as a camera system but some
*           functions must be redefined to manage inputs accordingly.
*
*   CONTRIBUTORS:
*       Ramon Santamaria:   Supervision, review, update and maintenance
*       Christoph Wagner:   Complete redesign, using raymath (2022)
*       Marc Palau:         Initial implementation (2014)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2022-2024 Christoph Wagner (@Crydsch) & Ramon Santamaria (@raysan5)
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

#ifndef RCAMERA_H
#define RCAMERA_H

''----------------------------------------------------------------------------------
'' Defines and Macros
''----------------------------------------------------------------------------------
'' Function specifiers definition

#define CAMERA_CULL_DISTANCE_NEAR   RL_CULL_DISTANCE_NEAR
#define CAMERA_CULL_DISTANCE_FAR    RL_CULL_DISTANCE_FAR

''----------------------------------------------------------------------------------
'' Module Functions Declaration
''----------------------------------------------------------------------------------

extern "C"

    declare function GetCameraForward(byval camera as Camera ptr) as Vector3
    declare function GetCameraUp(byval camera as Camera ptr) as Vector3
    declare function GetCameraRight(byval camera as Camera ptr) as Vector3

    '' Camera movement
    declare sub CameraMoveForward(byval camera as Camera ptr, byval distance as single, byval moveInWorldPlane as long)
    declare sub CameraMoveUp(byval camera as Camera ptr, byval distance as single)
    declare sub CameraMoveRight(byval camera as Camera ptr, byval distance as single, byval moveInWorldPlane as long)
    declare sub CameraMoveToTarget(byval camera as Camera ptr, byval delta as single)

    '' Camera rotation
    declare sub CameraYaw(byval camera as Camera ptr, byval angle as single, byval rotateAroundTarget as long)
    declare sub CameraPitch(byval camera as Camera ptr, byval angle as single, byval lockView as long, byval rotateAroundTarget as long, byval rotateUp as long)
    declare sub CameraRoll(byval camera as Camera ptr, byval angle as single)

    declare function GetCameraViewMatrix(byval camera as Camera ptr) as Matrix
    declare function GetCameraProjectionMatrix(byval camera as Camera ptr, byval aspect as single) as Matrix

end extern

#endif '' RCAMERA_H
