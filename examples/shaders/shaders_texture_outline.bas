/'******************************************************************************************
*
*   raylib [shaders] example - Apply an shdrOutline to a texture
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example contributed by Samuel Skiff (@GoldenThumbs) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Samuel SKiff (@GoldenThumbs) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - Apply an outline to a texture")

dim as Texture2D tex = LoadTexture("resources/fudesumi.png")

dim as Shader shdrOutline = LoadShader(0, TextFormat("resources/shaders/glsl%i/outline.fs", GLSL_VERSION))

dim as single outlineSize = 2.0f
dim as single outlineColor(3) = { 1.0f, 0.0f, 0.0f, 1.0f }     '' Normalized RED color
dim as single textureSize(1) = { tex.width, tex.height }

'' Get shader locations
dim as long outlineSizeLoc = GetShaderLocation(shdrOutline, "outlineSize")
dim as long outlineColorLoc = GetShaderLocation(shdrOutline, "outlineColor")
dim as long textureSizeLoc = GetShaderLocation(shdrOutline, "textureSize")

'' Set shader values (they can be changed later)
SetShaderValue(shdrOutline, outlineSizeLoc, @outlineSize, SHADER_UNIFORM_FLOAT)
SetShaderValue(shdrOutline, outlineColorLoc, @outlineColor(0), SHADER_UNIFORM_VEC4)
SetShaderValue(shdrOutline, textureSizeLoc, @textureSize(0), SHADER_UNIFORM_VEC2)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    outlineSize += GetMouseWheelMove()
    if outlineSize < 1.0f then outlineSize = 1.0f

    SetShaderValue(shdrOutline, outlineSizeLoc, @outlineSize, SHADER_UNIFORM_FLOAT)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginShaderMode(shdrOutline)

            DrawTexture(tex, GetScreenWidth()/2 - tex.width/2, -30, WHITE)

        EndShaderMode()

        DrawText("Shader-based\ntexture\noutline", 10, 10, 20, GRAY)
        DrawText("Scroll mouse wheel to\nchange outline size", 10, 72, 20, GRAY)
        DrawText(TextFormat("Outline size: %i px", outlineSize), 10, 120, 20, MAROON)

        DrawFPS(710, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(tex)
UnloadShader(shdrOutline)

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------