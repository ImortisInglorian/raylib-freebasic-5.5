/'******************************************************************************************
*
*   raylib [shaders] example - Texture Waves
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture waves")

'' Load texture texture to apply shaders
dim as Texture2D tex = LoadTexture("resources/space.png")

'' Load shader and setup location points and values
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/wave.fs", GLSL_VERSION))

dim as long secondsLoc = GetShaderLocation(shade, "seconds")
dim as long freqXLoc = GetShaderLocation(shade, "freqX")
dim as long freqYLoc = GetShaderLocation(shade, "freqY")
dim as long ampXLoc = GetShaderLocation(shade, "ampX")
dim as long ampYLoc = GetShaderLocation(shade, "ampY")
dim as long speedXLoc = GetShaderLocation(shade, "speedX")
dim as long speedYLoc = GetShaderLocation(shade, "speedY")

'' Shader uniform values that can be updated at any time
dim as single freqX = 25.0f
dim as single freqY = 25.0f
dim as single ampX = 5.0f
dim as single ampY = 5.0f
dim as single speedX = 8.0f
dim as single speedY = 8.0f

dim as single screenSize(1) = { GetScreenWidth(), GetScreenHeight() }
SetShaderValue(shade, GetShaderLocation(shade, "size"), @screenSize(0), SHADER_UNIFORM_VEC2)
SetShaderValue(shade, freqXLoc, @freqX, SHADER_UNIFORM_FLOAT)
SetShaderValue(shade, freqYLoc, @freqY, SHADER_UNIFORM_FLOAT)
SetShaderValue(shade, ampXLoc, @ampX, SHADER_UNIFORM_FLOAT)
SetShaderValue(shade, ampYLoc, @ampY, SHADER_UNIFORM_FLOAT)
SetShaderValue(shade, speedXLoc, @speedX, SHADER_UNIFORM_FLOAT)
SetShaderValue(shade, speedYLoc, @speedY, SHADER_UNIFORM_FLOAT)

dim as single seconds = 0.0f

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
'' -------------------------------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    seconds += GetFrameTime()

    SetShaderValue(shade, secondsLoc, @seconds, SHADER_UNIFORM_FLOAT)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginShaderMode(shade)

            DrawTexture(tex, 0, 0, WHITE)
            DrawTexture(tex, tex.width, 0, WHITE)

        EndShaderMode()

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)         '' Unload shader
UnloadTexture(tex)       '' Unload texture

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------