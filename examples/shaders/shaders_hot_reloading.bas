/'******************************************************************************************
*
*   raylib [shaders] example - Hot reloading
*
*   NOTE: This example requires raylib OpenGL 3.3 for shaders support and only #version 330
*         is currently supported. OpenGL ES 2.0 platforms are not supported at the moment.
*
*   Example originally created with raylib 3.0, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

#include "crt/time.bi"       '' Required for: localtime(), asctime()

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - hot reloading")

dim as zstring * 128 fragShaderFileName = "resources/shaders/glsl%i/reload.fs"
dim as time_t fragShaderFileModTime = GetFileModTime(TextFormat(fragShaderFileName, GLSL_VERSION))

'' Load raymarching shader
'' NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
dim as Shader shade = LoadShader(0, TextFormat(fragShaderFileName, GLSL_VERSION))

'' Get shader locations for required uniforms
dim as long resolutionLoc = GetShaderLocation(shade, "resolution")
dim as long mouseLoc = GetShaderLocation(shade, "mouse")
dim as long timeLoc = GetShaderLocation(shade, "time")

dim as single resolution(...) = { screenWidth, screenHeight }
SetShaderValue(shade, resolutionLoc, @resolution(0), SHADER_UNIFORM_VEC2)

dim as single totalTime = 0.0f
dim as boolean shaderAutoReloading = false

SetTargetFPS(60)                       '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()            '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    totalTime += GetFrameTime()
    dim as Vector2 mouse = GetMousePosition()
    dim as single mousePos(...) = { mouse.x, mouse.y }

    '' Set shader required uniform values
    SetShaderValue(shade, timeLoc, @totalTime, SHADER_UNIFORM_FLOAT)
    SetShaderValue(shade, mouseLoc, @mousePos(0), SHADER_UNIFORM_VEC2)

    '' Hot shader reloading
    if shaderAutoReloading or IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        dim as long currentFragShaderModTime = GetFileModTime(TextFormat(fragShaderFileName, GLSL_VERSION))

        '' Check if shader file has been modified
        if currentFragShaderModTime <> fragShaderFileModTime then
            '' Try reloading updated shader
            dim as Shader updatedShader = LoadShader(0, TextFormat(fragShaderFileName, GLSL_VERSION))

            if updatedShader.id <> rlGetShaderIdDefault() then      '' It was correctly loaded
                UnloadShader(shade)
                shade = updatedShader

                '' Get shader locations for required uniforms
                resolutionLoc = GetShaderLocation(shade, "resolution")
                mouseLoc = GetShaderLocation(shade, "mouse")
                timeLoc = GetShaderLocation(shade, "time")

                '' Reset required uniforms
                SetShaderValue(shade, resolutionLoc, @resolution(0), SHADER_UNIFORM_VEC2)
            end if

            fragShaderFileModTime = currentFragShaderModTime
        end if
    end if

    if IsKeyPressed(KEY_A) then shaderAutoReloading = not shaderAutoReloading
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' We only draw a white full-screen rectangle, frame is generated in shader
        BeginShaderMode(shade)
            DrawRectangle(0, 0, screenWidth, screenHeight, WHITE)
        EndShaderMode()

        DrawText(TextFormat("PRESS [A] to TOGGLE SHADER AUTOLOADING: %s",_
                    IIF(shaderAutoReloading, "AUTO", "MANUAL")), 10, 10, 10, iif(shaderAutoReloading, RED, BLACK))
        if not shaderAutoReloading then DrawText("MOUSE CLICK to SHADER RE-LOADING", 10, 30, 10, BLACK)

        DrawText(TextFormat("Shader last modification: %s", asctime(localtime(@fragShaderFileModTime))), 10, 430, 10, BLACK)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)           '' Unload shader

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------