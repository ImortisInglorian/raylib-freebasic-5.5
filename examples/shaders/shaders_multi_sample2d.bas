/'******************************************************************************************
*
*   raylib [shaders] example - Multiple sample2D with default batch system
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   Example originally created with raylib 3.5, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib - multiple sample2D")

dim as Image imRed = GenImageColor(800, 450, RLColor(255, 0, 0, 255))
dim as Texture texRed = LoadTextureFromImage(imRed)
UnloadImage(imRed)

dim as Image imBlue = GenImageColor(800, 450, RLColor(0, 0, 255, 255))
dim as Texture texBlue = LoadTextureFromImage(imBlue)
UnloadImage(imBlue)

dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/color_mix.fs", GLSL_VERSION))

'' Get an additional sampler2D location to be enabled on drawing
dim as long texBlueLoc = GetShaderLocation(shade, "texture1")

'' Get shader uniform for divider
dim as long dividerLoc = GetShaderLocation(shade, "divider")
dim as single dividerValue = 0.5f

SetTargetFPS(60)                           '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()                '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyDown(KEY_RIGHT) then
        dividerValue += 0.01f
    elseif IsKeyDown(KEY_LEFT) then
        dividerValue -= 0.01f
    end if

    if dividerValue < 0.0f then
        dividerValue = 0.0f
    elseif dividerValue > 1.0f then
        dividerValue = 1.0f
    end if

    SetShaderValue(shade, dividerLoc, @dividerValue, SHADER_UNIFORM_FLOAT)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginShaderMode(shade)

            '' WARNING: Additional samplers are enabled for all draw calls in the batch,
            '' EndShaderMode() forces batch drawing and consequently resets active textures
            '' to let other sampler2D to be activated on consequent drawings (if required)
            SetShaderValueTexture(shade, texBlueLoc, texBlue)

            '' We are drawing texRed using default sampler2D texture0 but
            '' an additional texture units is enabled for texBlue (sampler2D texture1)
            DrawTexture(texRed, 0, 0, WHITE)

        EndShaderMode()

        DrawText("Use KEY_LEFT/KEY_RIGHT to move texture mixing in shader!", 80, GetScreenHeight() - 40, 20, RAYWHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)       '' Unload shader
UnloadTexture(texRed)      '' Unload texture
UnloadTexture(texBlue)     '' Unload texture

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------