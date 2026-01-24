/'******************************************************************************************
*
*   raylib [textures] example - Texture drawing
*
*   NOTE: This example illustrates how to draw into a blank texture using a shader
*
*   Example originally created with raylib 2.0, last time updated with raylib 3.7
*
*   Example contributed by Michał Ciesielski and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Michał Ciesielski and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture drawing")

dim as Image imBlank = GenImageColor(1024, 1024, BLANK)
dim as Texture2D tex = LoadTextureFromImage(imBlank)  '' Load blank texture to fill on shader
UnloadImage(imBlank)

'' NOTE: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/cubes_panning.fs", GLSL_VERSION))

dim as single tme = 0.0f
dim as long timeLoc = GetShaderLocation(shade, "uTime")
SetShaderValue(shade, timeLoc, @tme, SHADER_UNIFORM_FLOAT)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
'' -------------------------------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    tme = GetTime()
    SetShaderValue(shade, timeLoc, @tme, SHADER_UNIFORM_FLOAT)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginShaderMode(shade)    '' Enable our custom shader for next shapes/textures drawings
            DrawTexture(tex, 0, 0, WHITE)  '' Drawing BLANK texture, all magic happens on shader
        EndShaderMode()            '' Disable our custom shader, return to default shader

        DrawText("BACKGROUND is PAINTED and ANIMATED on SHADER!", 10, 10, 20, MAROON)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)
UnloadTexture(tex)

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------