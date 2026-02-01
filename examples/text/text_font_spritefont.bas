/'******************************************************************************************
*
*   raylib [text] example - Sprite font loading
*
*   NOTE: Sprite fonts should be generated following this conventions:
*
*     - Characters must be ordered starting with character 32 (Space)
*     - Every character must be contained within the same Rectangle height
*     - Every character and every line must be separated by the same distance (margin/padding)
*     - Rectangles must be defined by a MAGENTA color background
*
*   Following those constraints, a font can be provided just by an image,
*   this is quite handy to avoid additional font descriptor files (like BMFonts use).
*
*   Example originally created with raylib 1.0, last time updated with raylib 1.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [text] example - sprite font loading")

dim as zstring * 50 msg1 = "THIS IS A custom SPRITE FONT..."
dim as zstring * 50 msg2 = "...and this is ANOTHER CUSTOM font..."
dim as zstring * 50 msg3 = "...and a THIRD one! GREAT! :D"

'' NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)
dim as Font font1 = LoadFont("resources/custom_mecha.png")          '' Font loading
dim as Font font2 = LoadFont("resources/custom_alagard.png")        '' Font loading
dim as Font font3 = LoadFont("resources/custom_jupiter_crash.png")  '' Font loading

dim as Vector2 fontPosition1 = Vector2(screenWidth/2.0f - MeasureTextEx(font1, msg1, font1.baseSize, -3).x/2, _
                            screenHeight/2.0f - font1.baseSize/2.0f - 80.0f)

dim as Vector2 fontPosition2 = Vector2(screenWidth/2.0f - MeasureTextEx(font2, msg2, font2.baseSize, -2.0f).x/2.0f, _
                            screenHeight/2.0f - font2.baseSize/2.0f - 10.0f)

dim as Vector2 fontPosition3 = Vector2(screenWidth/2.0f - MeasureTextEx(font3, msg3, font3.baseSize, 2.0f).x/2.0f, _
                            screenHeight/2.0f - font3.baseSize/2.0f + 50.0f)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTextEx(font1, msg1, fontPosition1, font1.baseSize, -3, WHITE)
        DrawTextEx(font2, msg2, fontPosition2, font2.baseSize, -2, WHITE)
        DrawTextEx(font3, msg3, fontPosition3, font3.baseSize, 2, WHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadFont(font1)      '' Font unloading
UnloadFont(font2)      '' Font unloading
UnloadFont(font3)      '' Font unloading

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------