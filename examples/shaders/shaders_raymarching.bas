/'******************************************************************************************
*
*   raylib [shaders] example - Raymarching shapes generation
*
*   NOTE: This example requires raylib OpenGL 3.3 for shaders support and only #version 330
*         is currently supported. OpenGL ES 2.0 platforms are not supported at the moment.
*
*   Example originally created with raylib 2.0, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_WINDOW_RESIZABLE)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - raymarching shapes")

dim as Camera cam
with cam
    .position = Vector3(2.5f, 2.5f, 3.0f)    '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.7f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 65.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

'' Load raymarching shader
'' NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/raymarching.fs", GLSL_VERSION))

'' Get shader locations for required uniforms
dim as long viewEyeLoc = GetShaderLocation(shade, "viewEye")
dim as long viewCenterLoc = GetShaderLocation(shade, "viewCenter")
dim as long runTimeLoc = GetShaderLocation(shade, "runTime")
dim as long resolutionLoc = GetShaderLocation(shade, "resolution")

dim as single resolution(...) = { screenWidth, screenHeight }
SetShaderValue(shade, resolutionLoc, @resolution(0), SHADER_UNIFORM_VEC2)

dim as single runTime = 0.0f

DisableCursor()                    '' Limit cursor to relative movement inside the window
SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FIRST_PERSON)

    dim as single cameraPos(...) = { cam.position.x, cam.position.y, cam.position.z }
    dim as single cameraTarget(...) = { cam.target.x, cam.target.y, cam.target.z }

    dim as single deltaTime = GetFrameTime()
    runTime += deltaTime

    '' Set shader required uniform values
    SetShaderValue(shade, viewEyeLoc, @cameraPos(0), SHADER_UNIFORM_VEC3)
    SetShaderValue(shade, viewCenterLoc, @cameraTarget(0), SHADER_UNIFORM_VEC3)
    SetShaderValue(shade, runTimeLoc, @runTime, SHADER_UNIFORM_FLOAT)

    '' Check if screen is resized
    if IsWindowResized() then
        resolution(0) = GetScreenWidth()
        resolution(1) = GetScreenHeight()
        SetShaderValue(shade, resolutionLoc, @resolution(0), SHADER_UNIFORM_VEC2)
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' We only draw a white full-screen rectangle,
        '' frame is generated in shader using raymarching
        BeginShaderMode(shade)
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), WHITE)
        EndShaderMode()

        DrawText("(c) Raymarching shader by Iñigo Quilez. MIT License.", GetScreenWidth() - 280, GetScreenHeight() - 20, 10, BLACK)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)           '' Unload shader

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------