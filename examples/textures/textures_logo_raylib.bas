/'******************************************************************************************
*
*   raylib [textures] example - Texture loading and drawing
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

InitWindow(screenWidth, screenHeight, "raylib [textures] example - texture loading and drawing")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
dim as Texture2D tex = LoadTexture("resources/raylib_logo.png")        '' Texture loading

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTexture(tex, screenWidth/2 - tex.width/2, screenHeight/2 - tex.height/2, WHITE)

        DrawText("this IS a texture!", 360, 370, 10, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(tex)       '' Texture unloading

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------