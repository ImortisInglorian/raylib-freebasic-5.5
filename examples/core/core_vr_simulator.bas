/'******************************************************************************************
*
*   raylib [core] example - VR Simulator (Oculus Rift CV1 parameters)
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION        330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

'' NOTE: screenWidth/screenHeight should match VR device aspect ratio
InitWindow(screenWidth, screenHeight, "raylib [core] example - vr simulator")

'' VR device parameters definition
dim as VrDeviceInfo device
with device
    '' Oculus Rift CV1 parameters for simulator
    .hResolution = 2160                 '' Horizontal resolution in pixels
    .vResolution = 1200                 '' Vertical resolution in pixels
    .hScreenSize = 0.133793f            '' Horizontal size in meters
    .vScreenSize = 0.0669f              '' Vertical size in meters
    .eyeToScreenDistance = 0.041f       '' Distance between eye and display in meters
    .lensSeparationDistance = 0.07f     '' Lens separation distance in meters
    .interpupillaryDistance = 0.07f     '' IPD (distance between pupils) in meters

    '' NOTE: CV1 uses fresnel-hybrid-asymmetric lenses with specific compute shaders
    '' Following parameters are just an approximation to CV1 distortion stereo rendering
    .lensDistortionValues(0) = 1.0f     '' Lens distortion constant parameter 0
    .lensDistortionValues(1) = 0.22f    '' Lens distortion constant parameter 1
    .lensDistortionValues(2) = 0.24f    '' Lens distortion constant parameter 2
    .lensDistortionValues(3) = 0.0f     '' Lens distortion constant parameter 3
    .chromaAbCorrection(0) = 0.996f     '' Chromatic aberration correction parameter 0
    .chromaAbCorrection(1) = -0.004f    '' Chromatic aberration correction parameter 1
    .chromaAbCorrection(2) = 1.014f     '' Chromatic aberration correction parameter 2
    .chromaAbCorrection(3) = 0.0f       '' Chromatic aberration correction parameter 3
end with

'' Load VR stereo config for VR device parameteres (Oculus Rift CV1 parameters)
dim as VrStereoConfig config = LoadVrStereoConfig(device)

'' Distortion shader (uses device lens distortion and chroma)
dim as Shader distortion = LoadShader(0, TextFormat("resources/distortion%i.fs", GLSL_VERSION))

'' Update distortion shader with lens and distortion-scale parameters
SetShaderValue(distortion, GetShaderLocation(distortion, "leftLensCenter"), @config.leftLensCenter(0), SHADER_UNIFORM_VEC2)
SetShaderValue(distortion, GetShaderLocation(distortion, "rightLensCenter"), @config.rightLensCenter(0), SHADER_UNIFORM_VEC2)
SetShaderValue(distortion, GetShaderLocation(distortion, "leftScreenCenter"), @config.leftScreenCenter(0), SHADER_UNIFORM_VEC2)
SetShaderValue(distortion, GetShaderLocation(distortion, "rightScreenCenter"),@config.rightScreenCenter(0), SHADER_UNIFORM_VEC2)

SetShaderValue(distortion, GetShaderLocation(distortion, "scale"), @config.scale(0), SHADER_UNIFORM_VEC2)
SetShaderValue(distortion, GetShaderLocation(distortion, "scaleIn"), @config.scaleIn(0), SHADER_UNIFORM_VEC2)
SetShaderValue(distortion, GetShaderLocation(distortion, "deviceWarpParam"), @device.lensDistortionValues(0), SHADER_UNIFORM_VEC4)
SetShaderValue(distortion, GetShaderLocation(distortion, "chromaAbParam"), @device.chromaAbCorrection(0), SHADER_UNIFORM_VEC4)

'' Initialize framebuffer for stereo rendering
'' NOTE: Screen size should match HMD aspect ratio
dim as RenderTexture2D target = LoadRenderTexture(device.hResolution, device.vResolution)

'' The target's height is flipped (in the source Rectangle), due to OpenGL reasons
dim as Rectangle sourceRec = Rectangle(0.0f, 0.0f, target.texture.width, -target.texture.height)
dim as Rectangle destRec = Rectangle(0.0f, 0.0f, GetScreenWidth(), GetScreenHeight())

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(5.0f, 2.0f, 5.0f)    '' Camera position
    .target = Vector3(0.0f, 2.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector
    .fovy = 60.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with
dim as Vector3 cubePosition = Vector3(0.0f, 0.0f, 0.0f)

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FIRST_PERSON)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginTextureMode(target)
        ClearBackground(RAYWHITE)
        BeginVrStereoMode(config)
            BeginMode3D(cam)

                DrawCube(cubePosition, 2.0f, 2.0f, 2.0f, RED)
                DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, MAROON)
                DrawGrid(40, 1.0f)

            EndMode3D()
        EndVrStereoMode()
    EndTextureMode()
    
    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginShaderMode(distortion)
            DrawTexturePro(target.texture, sourceRec, destRec, Vector2(0.0f, 0.0f), 0.0f, WHITE)
        EndShaderMode()
        DrawFPS(10, 10)
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadVrStereoConfig(config)   '' Unload stereo config

UnloadRenderTexture(target)    '' Unload stereo render fbo
UnloadShader(distortion)       '' Unload distortion shader

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------